function road(block)

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of dialog parameters   
  block.NumDialogPrms = 0;

  %% Register number of input and output ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 1;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.OutputPort(1).Dimensions = 1;
  
  %% Set block sample time to continuous
  block.OutputPort(1).SamplingMode = 'sample';
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 0;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  % block.RegBlockMethod('Derivatives',             @Derivative);  
  
%endfunction

function InitConditions(block)
%endfunction

function Output(block)
  % For lateral acceleration alpha * g, a 
  % change of curvature of alpha*g/u is required, where 
  % u is the speed of the vehicle
  global con;
  t = block.currentTime;

  % maxr = con.alpha_road*con.g/con.u0;
  % block.OutputPort(1).Data = 0 + (10<t)*(t<11)*maxr + (20<t)*(t<30)*(-maxr);

  radiusMin =  (con.u0^2)/(0.9*con.alpha_road*con.g);

  if t> 22
      radius=-radiusMin;
      rd = con.u0/radius;
  elseif t > 20
      alpha = (t-20)/2;
      rd= alpha * con.u0/(-radiusMin) + (1-alpha)*con.u0/radiusMin;
      
  elseif t> 11
      radius=radiusMin;
      rd = con.u0/radius;
  elseif t>10
      radius = radiusMin;
      rd = (t-10)*con.u0/radius;
  else
      rd=0;
  end

  block.OutputPort(1).Data = rd;

%endfunction