function rdot_to_delta(block)

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
 
  block.InputPort(1).Dimensions        = 4;
  block.InputPort(1).DirectFeedthrough = false;

  block.InputPort(2).Dimensions        = 1;
  block.InputPort(2).DirectFeedthrough = false;

  block.OutputPort(1).Dimensions       = 1;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 0;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('Outputs',                 @Output);  
  
%endfunction


function Output(block)
  global con;
  v = block.InputPort(1).Data(2);
  r = block.InputPort(1).Data(4);
  rdot = block.InputPort(2).Data;

  % rdot = k_v*v + k_r*r + k_d*delta_f
  k_d = con.a*con.Caf/con.Iz;
  k_v = (con.b*con.Car-con.a*con.Caf)/(con.Iz*con.u0);
  k_r = -(con.a^2*con.Caf + con.b^2*con.Car)/(con.Iz*con.u0);

  % Output delta_f
  block.OutputPort(1).Data = (rdot - k_v*v - k_r*r)/k_d;

%endfunction