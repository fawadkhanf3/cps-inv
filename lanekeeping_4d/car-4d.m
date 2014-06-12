function car(block)

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of dialog parameters   
  block.NumDialogPrms = 0;

  %% Register number of input and output ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;

  block.InputPort(2).Dimensions        = 1;
  block.InputPort(2).DirectFeedthrough = false;

  block.OutputPort(1).Dimensions       = 4;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 4;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Derivatives',             @Derivative);  
  
%endfunction

function InitConditions(block)
  block.ContStates.Data = [0 0 0 0]'; % initial condition
%endfunction

function Output(block)
  block.OutputPort(1).Data = block.ContStates.Data;

%endfunction

function Derivative(block)
  global con;

  delta_f =  block.InputPort(1).Data;
  r_d = block.InputPort(2).Data;
  x = block.ContStates.Data;

  A=[0 1 con.u0 0;
    0 -(con.Caf+con.Car)/con.m/con.u0 0 ((con.b*con.Car-con.a*con.Caf)/con.m/con.u0 - con.u0);
    0 0 0 1;
    0 (con.b*con.Car-con.a*con.Caf)/con.Iz/con.u0  0 -(con.a^2 * con.Caf + con.b^2 * con.Car)/con.Iz/con.u0];

  B=[0;con.Caf/con.m; 0; con.a*con.Caf/con.Iz];

  E=[0;0;1;0];

  global model;
  block.Derivatives.Data = A*x + B*delta_f + E*r_d;
  
%endfunction

