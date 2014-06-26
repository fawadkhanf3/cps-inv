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

  block.OutputPort(1).Dimensions       = 1;
  
  %% Set block sample time to continuous
  block.SampleTimes = [0 0];
  
  %% Setup Dwork
  block.NumContStates = 1;

  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Derivatives',             @Derivative);  
  
%endfunction

function DoPostPropSetup(block)

%endfunction

function InitConditions(block)
  block.ContStates.Data = 0;
  
  global Kp;
  global Ki;
  global Kv;
  % [Kp,Ki,Kv] = search_weights()

  Kp = 2
  Ki = 1
  Kv = 4
  % Kp = 2
  % Ki = 0.5
  % Kv = 2

  % Check if weights satisfy stability conditions
  weight_test = check_weights(Kp,Ki,Kv,1);

%endfunction

function Output(block)
  global Kp;
  global Ki;
  global Kv;
  global con;

  x =  block.InputPort(1).Data;
  v = x(1);
  h = x(2);
  v_L = x(3);
  z = block.ContStates.Data;

  u_nominal = con.mass*(Kp*(V(h)-v) + Ki*z + Kv*(min(v_L, con.v_des) - v));
  block.OutputPort(1).Data = u_nominal;

%endfunction

function Derivative(block)
  x =  block.InputPort(1).Data;
  v = x(1);
  h = x(2);
  v_L = x(3);
  z = block.ContStates.Data;

  ov = block.InputPort(2).Data;

  block.Derivatives.Data = [ (1-ov)*(V(h) - v)+ov*(-0.05*z) ];
  
%endfunction

function res = V(h)
  con = constants;
  gcon = gab_constants;

  res = (gcon.h_st<h).*(h<gcon.h_go)*(con.v_des/2).*(1-cos(pi*((h-gcon.h_st)./(gcon.h_go-gcon.h_st)))) + (h>=gcon.h_go)*con.v_des;
%endfunction

function [Kp,Ki,Kv] = search_weights()
  Kp=-1;
  Ki=-1;
  Kv=-1;
  for Kpt = 0.2:0.5:8
    for Kit = 0.1:0.1:10
      for Kvt = 0.1:0.2:2
        if check_weights(Kpt,Kit,Kvt)
          Kp = Kpt;
          Ki = Kit;
          Kv = Kvt;
          return
        end
      end
    end
  end

%endfunction

function passed_all = check_weights(Kp,Ki,Kv,verbose)
  if nargin<4
    verbose = 0;
  end

  con = constants;
  gcon = gab_constants;

  Kph = Kp; %/con.mass;
  Kih = Ki; %/con.mass;
  Kvh = Kv; %/con.mass;
  k = con.f2;
  m = con.mass;
  gam = con.f0/con.mass;

  passed_all = 1;

  for v_star = 5:5:25
    N_star = (pi/(gcon.h_go-gcon.h_st))*sqrt(v_star*(con.v_des-v_star));

    % test plant stability
    test1 = (Kph*N_star + Kih) * ((2*k/m)*v_star+Kph+Kvh) - Kih*N_star;
    if test1>0
      if  verbose 
        disp(['passed plant stability test for equilibrium ', num2str(v_star), ' m/s']);
      end
    else
      if verbose 
        disp(['failed plant stability test for equilibrium ', num2str(v_star), ' m/s']);
      end
      passed_all = 0;
      break;
    end      

    % test string stability
    alpha = -Kph^2 - 2*( 2*(k/m)*v_star + Kvh - N_star )*Kph - 4*(k/m)*v_star*((k/m)*v_star + Kvh) + 2*Kih;
    beta = Kih*(4*(k/m)*v_star*N_star - Kih);
    if alpha > 0
      test2 = alpha^2/4+beta;
    else
      test2 = beta;
    end
    if test2<0
      if verbose 
        disp(['passed string stability test for equilibrium ', num2str(v_star), ' m/s']);
      end
    else
      if verbose
        disp(['failed string stability test for equilibrium ', num2str(v_star), ' m/s']);
      end
      passed_all = 0;
      break;
    end      
  end

%endfunction

function gcon = gab_constants
  gcon.h_go = 35;
  gcon.h_st = 5;

%endfunction

