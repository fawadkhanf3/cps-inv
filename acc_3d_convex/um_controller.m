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
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Derivatives', @Derivatives);
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
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
end % DoPostPropSetup

function InitializeConditions(block)
  global pwadyn;
  global simple_dyn;
  global con;
  global set_chain;

  con = constants;
  pwadyn = get_pw_dyn(con);
  simple_dyn = get_simple_dyn(con);

  VH = pwadyn.domain;
  %Safe set
  S1 = intersect(VH, Polyhedron([1 -1 0; 0 -1 0], [0; -3]));
  % Goal set
  GA = [con.h_des-con.h_delta -1 0; 1 0 0];
  Gb = [0; con.v_des+con.v_delta];
  goal = intersect1(S1, Polyhedron('A', GA, 'b', Gb));

  % cinv = robust_cinv(pwadyn, goal); set_chain = bw_chain(pwadyn, cinv, S1);
  % save('set_chain_save.mat', 'set_chain')
  load set_chain_save

  assignin('base','con',con)
  assignin('base','pwadyn',pwadyn)
  assignin('base','simple_dyn',simple_dyn)
  assignin('base','set_chain',set_chain);

end %InitializeConditions


function Start(block)

end %Start


function Outputs(block)
  global pwadyn;
  global simple_dyn;
  global con;
  global set_chain;

  % disp('---------------------');
  x0 = block.InputPort(1).Data;
  v = x0(1);
  d = x0(2);
  vl = x0(3);

  if sum(abs(x0))==0
  % startup hack
    return;
  end

  if d >= con.d_max
    % Use controller for mode M2
    u = simple_dyn.solve_mpc(v, 1, -con.v_des, 0, 0, Polyhedron('A', [1; -1], 'b', [con.v_f_max; -con.v_f_min]));
    u_real = u(1)/(simple_dyn.get_constant('B_cond_number'));
    u_real = u_real + con.f2*(v-con.lin_speed)^2;
    % disp(['Trying to achieve v_des by applying ', num2str(u_real)]);
    block.OutputPort(1).Data = u_real;
    return;
  end

  region_dyn = pwadyn.get_region_dyn(x0); % active part of the pwa dynamics

  current_cell = find_cell(set_chain, x0);
  if current_cell == -1;
    disp('Cell not found, breaking hard')
    block.OutputPort(1).Data = con.umin;
    return;
  end

  N = 1;
  next_numbers = max(1, current_cell-[0:N-1]);
  next_polys = set_chain(next_numbers);
  % next_poly = set_chain(max(1, current_cell-1));


  [Rx,rx,Ru,ru] = mpcweights(v,d,vl,block.OutputPort(1).Data,N,con);

  % Get input wrt discrete model
  u = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, next_polys);

  % Rescale to interval u/m \in [umin, umax] and add nonlinearity
  u_real = u(1)/(region_dyn.get_constant('B_cond_number'));
  u_real = u_real + con.f2*(v-con.lin_speed)^2;

  % disp(['Trying to go from ', num2str(current_cell), ' to  ', num2str(next_numbers), ' by applying ', num2str(u_real)]);
              
  block.OutputPort(1).Data = u_real;

end %Outputs

function Update(block) 

end %Update

function Terminate(block)
end %Terminate

function ind = find_cell(puvec,x0)
  ind = -1;
  for i=1:size(puvec)
    if contains1(puvec(i),x0)
      ind = i; 
      return;
    end
  end
end

function  [Rx,rx,Ru,ru] = mpcweights(v,d,vl,udes,N,con)

  vdes = ramp(d, 5*vl, 1)*con.v_des + ramp(d, 5*vl, -1)*min(con.v_des,vl);

  Rx = zeros(3*N);
  rx = zeros(3*N,1);

  v_weight = 5;
  h_weight = 5*ramp(abs(v-vl), 5, 1);
  u_weight = 1;

  % weight on velocity
  Rx(sub2ind([3*N 3*N], 1:3:3*N, 1:3:3*N)) = v_weight*ones(N,1);
  rx(1:3:3*N) = v_weight*(-vdes)*ones(N,1);

  % weight on headway
  Rx(sub2ind([3*N 3*N], 2:3:3*N, 2:3:3*N)) = ramp(v, con.v_des, -1)*h_weight*ones(N,1);
  rx(2:3:3*N) = h_weight*(-1.4)*vl*ones(N,1)*ramp(v, con.v_des, -1);


  Ru = u_weight*eye(N);
  ru = zeros(N,1);
  % ru = -u_weight*udes*ones(N,1);
end

function weight = ramp(x, lim, sgn)
  weight = max(0, min(1, sign(sgn)*(-lim+x)/10));
end