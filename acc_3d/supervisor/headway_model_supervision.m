function headway_model_car(block)

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of dialog parameters   
  block.NumDialogPrms = 2;

  %% Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;

  block.OutputPort(1).Dimensions       = 2;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 2;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Derivatives',             @Derivative);  
  
%endfunction

function InitConditions(block)
  block.ContStates.Data = [block.DialogPrm(1).Data; block.DialogPrm(2).Data];
  
%endfunction

function Output(block)
  block.OutputPort(1).Data = block.ContStates.Data;
%endfunction

function Derivative(block)
  v = block.InputPort(1).Data;
  vl = block.ContStates.Data(2);

  block.Derivatives.Data = [vl - v; vldt(block.currentTime, vl)];
  
%endfunction

function dvl = vldt(t, vl)
  global con;
  amin = -0.97;
  dvl = (t>5)*(t<20)*(vl>3)*amin;
% end
