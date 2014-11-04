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
block.InputPort(1).Dimensions        = 2;
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
  global dyn;
  global dyn1d;
  global con;
  global control_chain;

  time_in_current = 0;
  current = Inf;

  warning('off', 'all'); % dont want to see QP warnings

  cd ..
    con = constants;
    dyn = get_2d_dyn(con);
  cd simulation
  dyn1d = Dyn(dyn.A(1,1),dyn.K(1,:),dyn.B(1,:),projection(dyn.XU_set, [1 3]));

  load control_chain

  assignin('base','con',con)
  assignin('base','dyn',dyn)
  assignin('base','dyn1d',dyn1d)
  assignin('base','control_chain',control_chain);

end %InitializeConditions


function Start(block)

end %Start


function Outputs(block)
  global control_chain;
  global dyn;
  global dyn1d;
  global con;

  N = 4;

  x0 = block.InputPort(1).Data;
  v = x0(1);
  d = x0(2);

  if d >= con.d_max
    % Use controller for mode M2
    safe_set = Polyhedron('A', [1; -1], 'b', [con.v_max; -con.v_min]);
    Rv = 5*eye(N);
    rv = -5*(con.v_des-1)*ones(N,1);
    Ru = eye(N);
    ru = zeros(N,1);
    u = dyn1d.solve_mpc(v, Rv, rv, Ru, ru, [safe_set, safe_set, safe_set, safe_set]);
    u_real = u(1)/(dyn.get_constant('B_cond_number'));
    u_real = u_real + con.f2*(v-con.v_linearize)^2;
    % disp(strcat({'M1: applying input '}, num2str(u_real)));        
    block.OutputPort(1).Data = u_real;
    return;
  end

  % We are in mode M1
  this_number = find_cell(control_chain, x0);
  if block.Dwork(1).Data == -1;
    % keep control constant
    return;
  end

  % Specify coming cells
  next_numbers = max(1, this_number-[1:N]);
  next_polys = control_chain(next_numbers);

  [Rx,rx,Ru,ru] = mpcweights(v,d,N,con);

  % Get input wrt discrete model
  u = dyn.solve_mpc(x0, Rx, rx, Ru, ru, next_polys);

  % Rescale to interval u/m \in [umin, umax] and add nonlinearity
  u_real = u(1)/(dyn.get_constant('B_cond_number'));
  u_real = u_real + con.f2*(v-con.v_linearize)^2;
              
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

function  [Rx,rx,Ru,ru] = mpcweights(v,d,N,con)

  v_goal = min(con.v_des-1, con.v_lead);
  h_goal = max(3, con.h_des*v);

  lim = 10;
  delta = 20;
  ramp = max(0, min(1, 0.5+abs(v-con.v_lead)/delta-lim/delta));

  v_weight = 3.;
  h_weight = 2.*(1-ramp);
  u_weight = 10;
  u_weight_jerk = 50;

  Rx = kron(eye(N), [v_weight 0; 0 h_weight]);
  rx = repmat([v_weight*(-v_goal); h_weight*(-h_goal)],N,1);

  Ru = u_weight*eye(N);
  if N>2
    Ru = Ru + u_weight_jerk*(diag([1 2*ones(1,N-2) 1]) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
  else
    Ru = Ru + u_weight_jerk*(diag(ones(1,N)) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
  end
  ru = zeros(N,1);

end