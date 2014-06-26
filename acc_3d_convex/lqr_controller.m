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

block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

end %setup


function InitializeConditions(block)
  global K;
  global con;

  con = constants;

  A = [ -con.f1_bar/con.mass 0;
      -1 0 ];
  B = [1/con.mass; 0];
  C = eye(2);
  D = zeros(2,1);

  umax = con.umax - con.f0_bar;
  umin = con.umin - con.f0_bar;

  sys = ss(A,B,C,D);

  Q = 1000*[1.4^2 -1.4;
     -1.4 1];
  R = 1;

  [K,S,E] = lqr(sys,Q,R)

end %InitializeConditions


function Outputs(block)
  global K;
  global con;
  x0 = block.InputPort(1).Data;
  v = x0(1);
  d = x0(2);
  vl = x0(3);

  u_lin = -K*[v;d];
  u_real = u_lin+con.f2*(v-con.lin_speed)^2;

  block.OutputPort(1).Data = u_real;

end %Outputs


function Terminate(block)
end %Terminate