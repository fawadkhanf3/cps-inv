function two_car_model(block)

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
 
  block.InputPort(1).Dimensions        = 3;
  block.InputPort(1).DirectFeedthrough = false;
  block.InputPort(2).Dimensions        = 1;
  block.InputPort(2).DirectFeedthrough = false;

  block.OutputPort(1).Dimensions       = 2;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 0;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  
%endfunction

function DoPostPropSetup(block)
  block.NumDworks = 1;
  block.Dwork(1).Name = 'time';
  block.Dwork(1).Dimensions = 1;
  block.Dwork(1).DataTypeID = 0;
  block.Dwork(1).Complexity = 'real';
  block.Dwork(1).UsedAsDiscState = true;
%endfunction

function InitConditions(block)
  global Cinv;
  global pwdyn;

  con = constants;
  pwdyn = get_pw_dyn(con);

  load set_chain_save;
  Cinv = set_chain(1);

  block.Dwork(1).Data = 0;
%endfunction

function Output(block)
  global Cinv;
  global pwdyn;
  global con;

  t = block.currentTime;
  tstop = block.Dwork(1).Data;

  x =  block.InputPort(1).Data;
  v = x(1);
  u_nominal = block.InputPort(2).Data;

  region_dyn = pwdyn.get_region_dyn(x);
  [HH, hh] = region_dyn.constraint_polytope2(Cinv);
  xu_poly = Polyhedron(HH,hh);
  u_nominal_scaled = (u_nominal-con.f2*(v-con.lin_speed)^2)*region_dyn.get_constant('B_cond_number');
  if true %xu_poly.contains([x; u_nominal_scaled]) && t>tstop;
    % use desired control
    block.OutputPort(1).Data = [u_nominal; 0];
    block.Dwork(1).Data = -1;
  else
    % take over
    u_mpc = region_dyn.solve_mpc(x, zeros(3), zeros(3,1), 1, -u_nominal_scaled, Cinv);
    u_mpc_real = u_mpc(1)/(region_dyn.get_constant('B_cond_number'));
    u_mpc_real = u_mpc_real + con.f2*(v-con.lin_speed)^2;
    block.OutputPort(1).Data = [u_mpc_real; 1];
    if tstop == -1
      block.Dwork(1).Data = t+2;
    end
  end
%endfunction