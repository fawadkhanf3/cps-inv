function two_car_model(block)

  setup(block);
  
%endfunction

function setup(block)
  
  %% Register number of dialog parameters   
  block.NumDialogPrms = 2;

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
  global safe_set;
  global pwdyn;
  global con;


  if block.DialogPrm(2).Data == 1
    disp('loading normal safe set')
    load safe_set_normal;
    con = constants_normal;
  elseif block.DialogPrm(2).Data == 2
    disp('loading aggressive safe set')
    load safe_set_aggressive;
    con = constants_aggressive;
  elseif block.DialogPrm(2).Data == 3
    disp('loading normal safe set w/ large vl')
    load safe_set_normal_largevl;
    con = constants_normal_largevl;
  else
    error('invalid parameter')
  end

  cd ..
    pwdyn = get_dyn2(con);
  cd supervisor
    
  block.Dwork(1).Data = 0;
%endfunction

function Output(block)
  global safe_set;
  global pwdyn;
  global con;

  t = block.currentTime;
  tstop = block.Dwork(1).Data;

  x =  block.InputPort(1).Data;
  v = x(1);
  u_nominal = block.InputPort(2).Data;

  if block.DialogPrm(1).Data == 0
    % turn off supervision
    block.OutputPort(1).Data = [u_nominal; 0];
    return
  end
  
  region_dyn = pwdyn.get_region_dyn(x);
  u_nominal_scaled = (u_nominal-con.f2*(v-con.lin_speed)^2)*region_dyn.get_constant('B_cond_number');

  if (t >= tstop)
  % check if nominal control makes state end up in any of the given polyhedra

    % for i=current_set:-1:max(1, current_set-1)
    for i=1:length(safe_set)
      [HH, hh] = region_dyn.constraint_polytope(safe_set(i));
      xu_poly = Polyhedron(HH,hh);

      if xu_poly.contains([x; u_nominal_scaled])
        % use desired control
        block.OutputPort(1).Data = [u_nominal; 0];
        block.Dwork(1).Data = -1;
        return;
      end
    end
  end

  % not found, taking over!

  current_set = -1;
  % find current part of safe set
  for i=1:length(safe_set)
    if (safe_set(i).contains(x))
      current_set = i;
      break;
    end
  end

  if current_set == -1
    disp('Not in safe set!!!')
    block.OutputPort(1).Data = [con.umin; 1];
    return;
  end

  [u1, c1] = region_dyn.solve_mpc(x, zeros(3), zeros(3,1), 1, -u_nominal_scaled, safe_set(current_set));
  [u2, c2] = region_dyn.solve_mpc(x, zeros(3), zeros(3,1), 1, -u_nominal_scaled, safe_set(max(1, current_set-1)));
  if (c1 < c2)
    u_mpc = u1;
  else
    u_mpc = u2;
  end
  u_mpc_real = u_mpc(1)/(region_dyn.get_constant('B_cond_number'));
  u_mpc_real = u_mpc_real + con.f2*(v-con.lin_speed)^2;
  block.OutputPort(1).Data = [u_mpc_real; 1];
  if tstop == -1
    block.Dwork(1).Data = t+1;
  end
%endfunction