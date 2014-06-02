function [sys,x0,str,ts] = simulink_discrete_system(t,x,u,flag)
 
% Generate a discrete linear system:
switch flag,
  case 0
    [sys,x0,str,ts] = mdlInitializeSizes(); % Initialization

  case 2
    sys = mdlUpdate(t,x,u); % Update discrete states

  case 3
    sys = mdlOutput(t,x,u); % Calculate outputs

  case {1, 4, 9} % Unused flags
    sys = [];

  otherwise
    error(['unhandled flag = ',num2str(flag)]); % Error handling
end
% End of dsfunc.

%==============================================================
% Initialization
%==============================================================

function [sys,x0,str,ts] = mdlInitializeSizes()

% Call simsizes for a sizes structure, fill it in, and convert it 
% to a sizes array.
con = constants;

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 2;
sizes.NumOutputs     = 2;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 1; % Matrix D is non-empty.
sizes.NumSampleTimes = 1;
sys = simsizes(sizes); 
x0  = [con.v0 con.d0]';   % Initialize the discrete states.
str = [];          % Set str to an empty matrix.
ts  = [con.dT 0];       % sample time: [period, offset]
% End of mdlInitializeSizes.

%==============================================================
% Update the discrete states
%==============================================================
function sys = mdlUpdate(t,x,u)
  global dyn;
  sys = dyn.apply_real(x, u);
  if t>100 && t<102
    sys(2) = 250;
  end 
% End of mdlUpdate.

%==============================================================
% Calculate outputs
%==============================================================
function sys = mdlOutput(t,x,u)
  global dyn;
  sys = dyn.apply_real(x, u);
% End of mdlOutputs.