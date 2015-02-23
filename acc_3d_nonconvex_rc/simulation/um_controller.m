function simulink_acc_controller(block)

setup(block);

end %function

function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 3;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = false;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1, 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

end %setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
block.NumDworks = 1;
  
  block.Dwork(1).Name            = 'cell_nr';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
end % DoPostPropSetup

function InitializeConditions(block)
  global pwadyn;
  global simple_dyn;
  global con;
  global set_mat;

  cd ..
    con = constants;
    pwadyn = get_dyn2(con);
  cd simulation
  simple_dyn = get_simple_dyn(con);

  load set_mat
  warning('off', 'all'); % dont want to see QP warnings

  assignin('base','con',con)
  assignin('base','pwadyn',pwadyn)
  assignin('base','simple_dyn',simple_dyn)
  assignin('base','set_mat',set_mat);

end %InitializeConditions


function Outputs(block)
  global pwadyn;
  global simple_dyn;
  global con;
  global set_mat;

  % disp('---------------------');
  x0 = block.InputPort(1).Data
  v = x0(1);
  h = x0(2);
  vl = x0(3);

  if sum(abs(x0))==0
  % startup hack
    return;
  end

  if h >= con.h_max
    % Use controller for mode M2
    u = simple_dyn.solve_mpc(v, 1, -con.v_des_max, 1, 0, Polyhedron('A', [1; -1], 'b', [con.v_max; -con.v_min]));
    u_real = u(1)/(simple_dyn.get_constant('B_cond_number'));
    u_real = u_real + con.f2*(v-con.lin_speed)^2;
    block.OutputPort(1).Data = u_real;
    return;
  end

  region_dyn = pwadyn.get_region_dyn(x0); % active part of the pwa dynamics

  [current_set current_poly] = find_cell(set_mat, x0);
  if current_set == -1;
    disp([num2str(block.currentTime), ': Cell not found for ', mat2str(x0), ', keeping constant'])
    % block.OutputPort(1).Data = con.umin;
    return;
  end

  [Rx,rx,Ru,ru] = mpcweights(v,h,vl,block.OutputPort(1).Data,1,con)

  if current_set == 1
    % We are in controlled-invariant set
    [u1, c1] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, set_mat{1}(current_poly));
    [u2, c2] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, set_mat{1}(max(1,current_poly-1)));
    if c1<c2
      u = u1;
    else
      u = u2;
    end
  else
    u = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, set_mat{current_set-1}(current_poly));
  end

  % Rescale to interval u/m \in [umin, umax] and add nonlinearity
  u_real = u(1)/(region_dyn.get_constant('B_cond_number'));
  u_real = u_real + con.f2*(v-con.lin_speed)^2

  % disp(['Trying to go from ', num2str(current_cell), ' to  ', num2str(next_numbers), ' by applying ', num2str(u_real)]);
              
  block.OutputPort(1).Data = u_real;

end %Outputs


function Terminate(block)
  warning('on', 'all');
end %Terminate

function [ind1 ind2] = find_cell(cmat,x0)
  ind1 = -1;
  ind2 = -1;
  for i=1:length(cmat)
    for j=1:length(cmat{i})
      if contains1(cmat{i}(j),x0)
        ind1 = i; 
        ind2 = j;
        return;
      end
    end
  end
end

function  [Rx,rx,Ru,ru] = mpcweights(v,d,vl,udes,N,con)

  v_goal = min((con.v_des_max+con.v_des_min)/2, vl);
  h_goal = max(3, con.tau_des*v);

  lim = 0.3;
  delta = 0.6;
  ramp = max(0, min(1, 0.5+abs(v-vl)/delta-lim/delta));

  v_weight = 3.;
  h_weight = 5.*(1-ramp);
  u_weight = 3;

  Rx = kron(eye(N), [v_weight 0 0; 0 h_weight 0; 0 0 0]);
  rx = repmat([v_weight*(-v_goal); h_weight*(-h_goal); 0],N,1);

  Ru = u_weight*eye(N);
  ru = zeros(N,1);

end