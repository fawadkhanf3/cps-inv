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

  block.OutputPort(1).Dimensions       = 3;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 3;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Derivatives',             @Derivative);  
  
%endfunction

function InitConditions(block)
  block.ContStates.Data = [0.2; 0.04; 0.0]'; % initial condition
%endfunction

function Output(block)
  block.OutputPort(1).Data = block.ContStates.Data;

%endfunction

function Derivative(block)
  rdot_car = block.InputPort(1).Data;
  r_road = block.InputPort(2).Data;
  x = block.ContStates.Data;

  global con;
  block.Derivatives.Data = [0 con.u0 0; 0 0 1; 0 0 0]*x + [0; 0; 1]*rdot_car + [0; 1; 0]*r_road;
  
%endfunction

