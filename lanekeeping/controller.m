function controller(block)

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

% Override input port properties
% block.InputPort(2).Dimensions        = 1;
% block.InputPort(2).DatatypeID  = 0;  % double
% block.InputPort(2).Complexity  = 'Real';
% block.InputPort(2).DirectFeedthrough = false;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 1;

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
  block.NumDworks = 0;
end % DoPostPropSetup

function InitializeConditions(block)
  global con;
  global C;
  global dyn;
  global opts;
  % Find the invariant set
  con = constants;
  dyn = get_dyn(con);

  ymax = 0.9; %half lane width
  rmax = con.a*con.u0*con.F_yfmax/(con.b^2*con.Car);

  domain = Polyhedron('A', [eye(3); -eye(3)], ...
            'b', [2*ymax; 0.15; 2*rmax; 2*ymax; 0.15; 2*rmax]);

  safe = Polyhedron('A', [1 0 0;
              -1 0 0;
              0 0  1;
              0 0 -1], ...
            'b', [ymax;
                  ymax;
                  rmax;
                  rmax] ...
            );
  safe = intersect1(safe,domain);

  opts = optimoptions('quadprog','Algorithm','interior-point-convex','display','None');
  warning('off', 'all'); % dont want to see QP warnings

  C = dyn.cinv_oi(safe, 1, 1e-3, 1);
end %InitializeConditions


function Start(block)
  block.OutputPort(1).Data = [0];
end %Start


function Outputs(block)
  global con;
  global C;
  global dyn;
  global opts;

  % read input - vehicle state and road curvature
  x = block.InputPort(1).Data;

  N = 14;
  [rdot, cost] = dyn.solve_mpc(x, eye(N*3), zeros(N*3,1), 4*eye(N), zeros(N,1), repmat(C,1,N), opts);

  block.OutputPort(1).Data = rdot(1);

end %Outputs

function Update(block) 

end %Update

function Terminate(block)
  global con;
  global C;
  global dyn;
  clear con C dyn opts;

  warning('on', 'all');

end %Terminate