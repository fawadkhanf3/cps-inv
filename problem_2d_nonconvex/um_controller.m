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
  global con;
  global vp;
  global time_in_current;
  global current;

  time_in_current = 0;
  current = Inf;

  con = constants;
  dyn = get_2d_dyn(con);
  % [vp1, vp2] = get_control_sets_2d(dyn, con, 0);
  % vp = [vp1 vp2];
  % save('um_save', 'vp');
  load um_save

  assignin('base','con',con)
  assignin('base','dyn',dyn)
  assignin('base','vp',vp);

end %InitializeConditions


function Start(block)

end %Start


function Outputs(block)
  global vp;
  global dyn;
  global con;
  global current;
  global time_in_current;

  disp('---------------------');
  x0 = block.InputPort(1).Data;
  v = x0(1);
  d = x0(2);

  if d >= con.d_max
    % Use controller for mode M2
    [Rx,rx,Ru,ru] = mpcweights(v,d,5,con);
    u = dyn.solve_mpc(x0, Rx, rx, Ru, ru, [vp(end), vp(end), vp(end), vp(end), vp(end)]);
    u_real = u(1)/(dyn.get_constant('B_cond_number'));
    u_real = u_real + con.f2*(v-con.v_linearize)^2;
    disp(strcat({'Applying input '}, num2str(u_real)));        
    block.OutputPort(1).Data = u_real;
    return;
  end

  block.Dwork(1).Data = find_cell(vp, x0);
  if block.Dwork(1).Data == -1;
    disp('Cell not found, applying input 0')
    block.OutputPort(1).Data = 0;
    return;
  end

  this_number = block.Dwork(1).Data;
  if this_number ~= current
    current = this_number;
    time_in_current = 0;
  else
    time_in_current = time_in_current+1;
  end

  N = 4;

  if time_in_current>50
    disp('too long!!')
    next_numbers = max(1, this_number-[1:N]);
  else
    next_numbers = max(1, this_number-[0:N-1]);
  end

  next_polys = vp(next_numbers);

  disp(strcat({'Trying to go from '}, num2str(this_number), {' to  '}, num2str(next_numbers)));


  [Rx,rx,Ru,ru] = mpcweights(v,d,N,con);

  % Get input wrt discrete model
  u = dyn.solve_mpc(x0, Rx, rx, Ru, ru, next_polys);

  % Rescale to interval u/m \in [umin, umax] and add nonlinearity
  u_real = u(1)/(dyn.get_constant('B_cond_number'));
  u_real = u_real + con.f2*(v-con.v_linearize)^2;

  disp(strcat({'Applying input '}, num2str(u_real)));
              
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
  if d < 4*con.v_des
      % follow line between (vl, 1.4 vl) and (v, d)
      % this line has equation [a1 a2] [v h]' = b
      V = null([ con.v_lead 1.4*con.v_lead -1; v d -1]);
      a1 = V(1);
      a2 = V(2);
      b = V(3);

      line_weight=2;

      wm = line_weight*[a1^2 -a1*a2; -a1*a2 a2^2];
      Rx = repmat({wm}, 1, N);
      Rx = blkdiag(Rx{:});
      rx = line_weight*repmat(b*[a1; a2], N,1);
      
      % vl_weight = 1;
      % Rx2 = zeros(2*N);
      % rx2 = zeros(2*N,1);
      % Rx2(2*N-1, 2*N-1) = vl_weight;
      % rx2(2*N-1) = -vl_weight*con.v_lead;

      % Rx = Rx1+Rx2;
      % rx = rx1+rx2;
  else
      d_des_weight = 0;
      d_des = 0;
      v_des_weight = 3;
      v_des = con.v_des;
      % Rx = repmat({[ v_des_weight 0; 0 d_des_weight ]},1,N); 
      % Rx = blkdiag(Rx{:});
      % rx = repmat([ -v_des_weight*con.v_des ;-d_des_weight*d_des ], N,1);
      Rx = zeros(2*N);
      rx = zeros(2*N,1);
      Rx(1,1) = v_des_weight;
      rx(1) = -v_des_weight*con.v_des;
      % Rx(3,3) = 0.5*v_des_weight;
      % rx(3) = -0.5*v_des_weight*con.v_des;
  end

  Ru = eye(N)+3*(eye(N)-ones(N))*(eye(N)-ones(N)); % try to have all u close to mean
  ru = zeros(N,1);
end