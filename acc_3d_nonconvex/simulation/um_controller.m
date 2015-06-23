function simulink_acc_controller(block)

setup(block);

end %function

function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 3;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = false;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1, 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Terminate', @Terminate); % Required

end %setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
block.NumDworks = 1;
  
  block.Dwork(1).Name            = 'cell_nr';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
end % DoPostPropSetup

function InitializeConditions(block)
  global pwadyn;
  global simple_dyn;
  global con;
  global M1;
  global C1_full;
  global C1_reach;
  global M2;
  global C2_full;
  global C2_reach;
  global in_c1_reach;

  load case3

  cd ..
    con = constants_benign;
    pwadyn = get_dyn2(con);
  cd simulation
  simple_dyn = get_simple_dyn(con);

  warning('off', 'all'); % dont want to see QP warnings

  in_c1_reach = false;

  assignin('base','con',con)
  assignin('base','pwadyn',pwadyn)
  assignin('base','simple_dyn',simple_dyn)
  assignin('base','M1',M1);
  assignin('base','C1_full',C1_full);
  assignin('base','C1_reach',C1_reach);
  assignin('base','M2',M2);
  assignin('base','C2_full',C2_full);
  assignin('base','C2_reach',C2_reach);

end %InitializeConditions

function Outputs(block)
  global pwadyn;
  global simple_dyn;
  global con;
  global M1;
  global C1_full;
  global C1_reach;
  global M2;
  global C2_full;
  global C2_reach;
  global in_c1_reach;

  % disp('---------------------');
  x0 = block.InputPort(1).Data;
  v = x0(1);
  h = x0(2);
  vl = x0(3);

  if sum(abs(x0))==0
  % startup hack
    return;
  end

  if h >= con.h_max
    % Use controller for no lead car hybrid state
    u = simple_dyn.solve_mpc(v, 1, -con.v_des, 1, 0, Polyhedron('A', [1; -1], 'b', [con.v_max; -con.v_min]));
    u_real = u(1)/(simple_dyn.get_constant('B_cond_number'));
    u_real = u_real + con.f2*(v-con.lin_speed)^2;
    block.OutputPort(1).Data = u_real;
    return;
  end

  region_dyn = pwadyn.get_region_dyn(x0); % active part of the pwa dynamics

  [Rx,rx,Ru,ru] = mpcweights(v,h,vl,block.OutputPort(1).Data,1,con);

  if (M1.contains(x0))
    cont = C1_reach.contains(x0);
    if (in_c1_reach || any(cont))
      % in controlled invariant set, should stay there
      in_c1_reach = true;

      if (~any(cont))
        % disp('fell out, should keep constant')
        return;
      else
        ind = find(cont, 1, 'first');
        [u1, c1] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, C1_reach(max(1, ind-1)));
        [u2, c2] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, C1_reach(ind));
        if c1<c2
          u = u1;
        else
          u = u2;
        end
      end
      % disp([num2str(block.currentTime), ' in C1_reach'])
    else
      % must make progress towards invariant set
      cont = C1_full.contains(x0);
      if ~any(cont)
        error('not in C1 set')
      else
        ind = find(cont, 1, 'first');
        [u, c] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, C1_full(ind-1));
      end
      % disp([num2str(block.currentTime), ' in C1_full'])
    end
  elseif (M2.contains(x0))
    in_c1_reach = false;
    cont = C2_reach.contains(x0);
    if (any(cont))
      % in controlled invariant set, should stay there
      ind = find(cont, 1, 'first');
      [u1, c1] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, C2_reach(max(1, ind-1)));
      [u2, c2] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, C2_reach(ind));
      if c1<c2
        u = u1;
      else
        u = u2;
      end
      % disp([num2str(block.currentTime), 'in C2_reach'])
    else
      % must make progress towards invariant set
      cont = C2_full.contains(x0);
      if ~any(cont)
        error('not in C2 set')
      else
        ind = find(cont, 1, 'first');
        [u, c] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, C2_full(ind-1));
      end
      % disp([num2str(block.currentTime), 'in C2_full'])
    end
  else
    error('not inside a goal region')
  end

  % Rescale to interval u/m \in [umin, umax] and add nonlinearity
  u_real = u(1)/(region_dyn.get_constant('B_cond_number'));
  u_real = u_real + con.f2*(v-con.lin_speed)^2;
              
  block.OutputPort(1).Data = u_real;

end %Outputs


function Terminate(block)
  warning('on', 'all');
end %Terminate

function  [Rx,rx,Ru,ru] = mpcweights(v,d,vl,udes,N,con)

  v_goal = min(con.v_des, vl);
  h_goal = max(3, con.tau_des*v);

  lim = 10;
  delta = 20;
  ramp = max(0, min(1, 0.5+abs(v-vl)/delta-lim/delta));

  v_weight = 3.;
  h_weight = 5.*(1-ramp);
  u_weight = 3;
  u_weight_jerk = 50;

  Rx = kron(eye(N), [v_weight 0 0; 0 h_weight 0; 0 0 0]);
  rx = repmat([v_weight*(-v_goal); h_weight*(-h_goal); 0],N,1);

  Ru = u_weight*eye(N);
  if N>2
    Ru = Ru + u_weight_jerk*(diag([1 2*ones(1,N-2) 1]) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
  else
    Ru = Ru + u_weight_jerk*(diag(ones(1,N)) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
  end
  ru = zeros(N,1);

end