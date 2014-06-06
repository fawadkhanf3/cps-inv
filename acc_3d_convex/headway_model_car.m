function headway_model_car(block)

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of dialog parameters   
  block.NumDialogPrms = 1;

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
  block.ContStates.Data = [block.DialogPrm(1).Data; 14];
  
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
  con = constants;
  amax = 0.9*con.d_max_ratio*(con.umax - con.f0 - con.f1*vl - con.f2*vl^2)/con.mass;
  amin = 0.9*con.d_max_ratio*(con.umin - con.f0 - con.f1*vl - con.f2*vl^2)/con.mass;
  dvl = (t>20)*(t<30)*(vl<25)*amax + ...
        (t>35)*(t<50)*(vl<34)*amax + ...
        (t>60)*(t<80)*(vl>10)*amin + ...
        (t>110)*(t<120)*(vl>0)*max(amin, -vl) + ...
        (t>130)*(t<160)*(vl<22)*amax;
% end
