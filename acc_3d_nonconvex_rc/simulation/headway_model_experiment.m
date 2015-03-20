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
  block.NumContStates = 1;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Derivatives',             @Derivative);  
  
%endfunction


function InitConditions(block)
  block.ContStates.Data = block.DialogPrm(1).Data;
  file = 'experiment.txt';
  
  M = csvread(file, 1,0);
  M(:,1) = (M(:,1)-M(1,1))/10^9;

  global experiment_data;
  global time_start;
  experiment_data = M;
  time_start = 5;
  % assignin('base','experiment_data',M);

%endfunction

function Output(block)
  global experiment_data;
  global time_start;
  t = block.currentTime;
  vlind = find(experiment_data(:,1) <= time_start + block.currentTime, 1, 'last');
  t0 = experiment_data(vlind, 1);
  t1 = experiment_data(vlind+1, 1);
  v0 = experiment_data(vlind, 4);
  v1 = experiment_data(vlind+1, 4);

  vl = v0 + (v1 - v0) * (time_start + t - t0)/(t1-t0);
  block.OutputPort(1).Data = [block.ContStates.Data vl];
%endfunction

function Derivative(block)
  v = block.InputPort(1).Data;
  vl = block.OutputPort(1).Data(2);

  block.Derivatives.Data = vl - v;
  
%endfunction