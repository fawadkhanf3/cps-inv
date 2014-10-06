function simulink_acc_controller(block)

setup(block);

end %function

function setup(block)

% Register number of ports
block.NumInputPorts  = 2;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 2;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = false;

block.InputPort(2).Dimensions        = 1;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = false;

% Override output port properties
block.OutputPort(1).Dimensions       = 4;
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
block.NumDworks = 3;
  
  block.Dwork(1).Name            = 'P';
  block.Dwork(1).Dimensions      = 16;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;

  block.Dwork(2).Name            = 'x';
  block.Dwork(2).Dimensions      = 4;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;

  block.Dwork(3).Name            = 'lasttime';
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0;      % double
  block.Dwork(3).Complexity      = 'Real'; % real
  block.Dwork(3).UsedAsDiscState = true;

end % DoPostPropSetup

function InitializeConditions(block)
  block.Dwork(1).Data = vec(eye(4));
  block.Dwork(2).Data = [28;250;12;0];
  block.Dwork(3).Data = 0;
end %InitializeConditions


function Outputs(block)
  con = constants;
  y = block.InputPort(1).Data;
  u = block.InputPort(2).Data;
  u = u - con.f2*(y(1)-con.lin_speed)^2;
  P = mat(block.Dwork(1).Data);
  x = block.Dwork(2).Data;

  dt = block.CurrentTime - block.Dwork(3).Data;
  if dt>0.3
    block.Dwork(3).Data = block.CurrentTime;
    
    con = constants;

    f0_bar = con.f0_bar;
    f1_bar = con.f1_bar;
    mass = con.mass;

    %
    % Model: x(k+1) = Ax(k) + Bu(k) + K + w
    %        y(k) = C*x(k) + v
    %  where w ~ N(0,Q), v ~ N(0,R)
    % 

    % Calculate discrete dynamics (depends on dt!)

  kappa = f1_bar/mass;
  ekt = exp(-kappa*dt);

  A = [ ekt         0     0      0; 
        (ekt-1)/kappa   1     dt     dt^2/2;
        0       0     1      dt;
        0         0       0      1]; 
  B = (1/(f1_bar^2))*[ f1_bar*(1-ekt) ;
                 mass*(1-ekt) - dt*f1_bar ;
                 0;
                 0 ];

  K = [ (f0_bar/f1_bar)*(ekt-1) ;
      (f0_bar/(f1_bar^2) )*(dt*f1_bar + mass*(ekt-1)) ;
      0;
      0 ];

    C = [1 0 0 0; 0 1 0 0];

    Q = diag([0 dt^3/3 dt^2/2 dt]);
    R = 0.1*dt*eye(2);

    % Do Kalman updates
    x_next_pred = A*x + B*u + K;
    P_next_pred = A*P*A' + Q;

    inn = y - C*x_next_pred;
    inn_convar = C*P_next_pred*C' + R;

    gain = P_next_pred*C'*inv(inn_convar);

    x_next = x_next_pred + gain*inn;
    P_next = (eye(4)-gain*C)*P_next_pred;

    block.Dwork(1).Data = vec(P_next);
    block.Dwork(2).Data = x_next;

    block.OutputPort(1).Data = x_next;
  end

end %Outputs


function Terminate(block)

end %Terminate
