function two_car_model(block)

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of dialog parameters   
  block.NumDialogPrms = 0;

  %% Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 3;
  block.InputPort(1).DirectFeedthrough = false;

  block.OutputPort(1).Dimensions       = 1;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 0;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('Outputs',                 @Output);  
  
%endfunction

function DoPostPropSetup(block)

%endfunction


function Output(block)
  global con;

  x =  block.InputPort(1).Data;
  v = x(1);
  h = x(2);

  k = 500;

  v_target = min(con.v_des, h/con.tau_des);

  block.OutputPort(1).Data = con.f0 + con.f1*v + con.f2*v^2 -k*(v - v_target);
  
%endfunction

