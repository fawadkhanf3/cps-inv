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
block.InputPort(1).Dimensions        = 2;
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
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Derivatives', @Derivatives);
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
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
end % DoPostPropSetup

function InitializeConditions(block)
  global dyn;
  global dyn1d;
  global con;
  global control_chain;

  time_in_current = 0;
  current = Inf;

  con = constants;
  dyn = get_2d_dyn(con);
  dyn1d = Dyn(dyn.A(1,1),dyn.B(1,:),dyn.K(1,:),dyn.E(1,:),projection(dyn.XU_set, [1 3]));
  control_chain = get_control_sets_2d(dyn, con, 0);

  assignin('base','con',con)
  assignin('base','dyn',dyn)
  assignin('base','dyn1d',dyn1d)
  assignin('base','control_chain',control_chain);

end %InitializeConditions


function Start(block)

end %Start


function Outputs(block)
  global control_chain;
  global dyn;
  global dyn1d;
  global con;

  disp('---------------------');

  N = 4;

  x0 = block.InputPort(1).Data;
  v = x0(1);
  d = x0(2);

  if d >= con.d_max
    % Use controller for mode M2
    safe_set = Polyhedron('A', [1; -1], 'b', [con.v_max; -con.v_min]);
    Rv = 5*eye(N);
    rv = -5*con.v_des*ones(N,1);
    Ru = eye(N);
    ru = zeros(N,1);
    u = dyn1d.solve_mpc(v, Rv, rv, Ru, ru, [safe_set, safe_set, safe_set, safe_set]);
    u_real = u(1)/(dyn.get_constant('B_cond_number'));
    u_real = u_real + con.f2*(v-con.v_linearize)^2;
    disp(strcat({'M1: applying input '}, num2str(u_real)));        
    block.OutputPort(1).Data = u_real;
    return;
  end

  % We are in mode M1
  this_number = find_cell(control_chain, x0);
  if block.Dwork(1).Data == -1;
    error('Cell not found!')
  end

  % Specify coming cells
  next_numbers = max(1, this_number-[1:N]);
  next_polys = control_chain(next_numbers);

  disp(strcat({'Trying to go from '}, num2str(this_number), {' to  '}, num2str(next_numbers)));

  [Rx,rx,Ru,ru] = mpcweights(v,d,N,con);

  % Get input wrt discrete model
  u = dyn.solve_mpc(x0, Rx, rx, Ru, ru, next_polys);

  % Rescale to interval u/m \in [umin, umax] and add nonlinearity
  u_real = u(1)/(dyn.get_constant('B_cond_number'));
  u_real = u_real + con.f2*(v-con.v_linearize)^2;

  disp(strcat({'M2: applying input '}, num2str(u_real)));
              
  block.OutputPort(1).Data = u_real;

end %Outputs

function Update(block) 

end %Update

function Terminate(block)
end %Terminate

function ind = find_cell(puvec,x0)
  ind = -1;
  for i=1:size(puvec)
    if contains1(puvec(i),x0)
      ind = i;
      return;
    end
  end
end

function  [Rx,rx,Ru,ru] = mpcweights(v,d,N,con)
  if d < 90

      %%%%%%%%%% Punish deviations from line between (vl, 1.4 vl) and (v, d) %%%%%%%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      % this line has equation [a1 a2] [v h]' = b
      % V = null([ con.v_lead 1.4*con.v_lead -1; v d -1]);
      % a1 = V(1); a2 = V(2); b = V(3);

      % wm = [a1^2 -a1*a2; -a1*a2 a2^2];
      % Rx_line = repmat({wm}, 1, N);
      % Rx_line = blkdiag(Rx_line{:})
      % rx_line = repmat(b*[a1; a2], N,1)

      % Treat as parametrized line x(t) = (vl, 1.4 vl) + t (v-vl, d-1.4 vl), t : 0 --> 1

      v_weight = max(1, abs(d-con.v_lead*con.v_des))  % normalize wrt error
      d_weight = (1+5*(v-con.v_des)/(con.v_lead-con.v_des) )*max(1, abs(v-con.v_lead)) % normalize wrt error

      t_steps = 0.9:-0.9/(N-1):0;
      % t_steps = zeros(1,N);
      Rx_line = diag(repmat([v_weight d_weight], 1, N));
      rx_line = - repmat([v_weight*con.v_lead; d_weight*con.h_des*con.v_lead],N,1) - ...
                kron(t_steps',[v_weight; d_weight]).*repmat([v-con.v_lead; d- con.h_des*con.v_lead],N,1);

      %%%%%%%%%% Punish deviations from fixed point %%%%%%%
      Rx_fixed_point = diag(repmat([v_weight d_weight],1,N));
      rx_fixed_point = repmat([-v_weight*con.v_lead; d_weight*con.h_des*con.v_lead], N, 1);
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      u_weight = max(v_weight, d_weight);
      line_weight = 3;
      fixed_point_weight = 0;

      Rx = line_weight*Rx_line + fixed_point_weight*Rx_fixed_point;
      rx = line_weight*rx_line + fixed_point_weight*rx_fixed_point;
  else
      v_des_weight = 30;
      u_weight = 1;

      Rx = zeros(2*N);
      rx = zeros(2*N,1);
      Rx(1,1) = v_des_weight;
      rx(1) = -v_des_weight*con.v_des;
  end

  Ru = u_weight*(eye(N)+3*(eye(N)-ones(N))*(eye(N)-ones(N))); % try to have all u close to mean
  ru = zeros(N,1);
end