%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%  These are parameters %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define initial state
x0 = [0.3; 4; 2];

final_poly = set_mat{1}(1);

dyn = pwadyn.get_region_dyn(x0);

Hx = final_poly.A;
hx = final_poly.b;

v_des = (con.v_des_max + con.v_des_min)/2;
h_safe = con.h_min;
tau_des = con.tau_des;

N = 1;  % horizon

v = x0(1);
v_lead = x0(3);

con_v_weight = 1;
con_h_weight = 5;
con_u_weight = 100;
con_u_weight_jerk = 10;
ramp_lim = 0.3; 
ramp_delta = 0.6;

v_goal = min(v_des, v_lead);
h_goal = max(h_safe, tau_des*v);

ramp = max(0, min(1, 0.5+abs(v-v_lead)/ramp_delta-ramp_lim/ramp_delta));

v_weight      = con_v_weight;
h_weight      = con_h_weight*(1-ramp);
u_weight      = con_u_weight;
u_weight_jerk = con_u_weight_jerk;

Rx = [ v_weight 0 0;
      0 h_weight 0;
      0 0 0];

rx = [ v_weight*(-v_goal);
     h_weight*(-h_goal);
     0];

Ru = u_weight;
ru = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Computations start here %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = size(dyn.A,2);  % dimension of state space
m = size(dyn.B,2);  % dimension of input space
p = size(dyn.E,2);  % dimension of disturbance space


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create dynamics matrices %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Lx = zeros(n*N, n);
Lu = zeros(n*N, m*N);
Ld = zeros(n*N, p*N);
Lk = zeros(n*N, N);

AN =  dyn.A;
ANB = dyn.B;
ANE = dyn.E;
ANK = dyn.K;

for i=1:N
	diag_mat = kron(eye(N+1-i), ANB);
    Lu(1+n*(i-1):end,1:m*(N+1-i)) = Lu(1+n*(i-1):end,1:m*(N+1-i)) + diag_mat;

    diag_mat = kron(eye(N+1-i), ANK);
    Lk(1+n*(i-1):end,1:(N+1-i)) = Lk(1+n*(i-1):end,1:(N+1-i)) + diag_mat;

    if p>0
	    diag_mat = kron(eye(N+1-i), ANE);
	    Ld(1+n*(i-1):end,1:p*(N+1-i)) = Ld(1+n*(i-1):end,1:p*(N+1-i)) + diag_mat;
	end
	
    Lx(1+n*(i-1):n*i,:) = AN;

    ANB = dyn.A*ANB;
    ANK = dyn.A*ANK;
    ANE = dyn.A*ANE;
    AN =  dyn.A*AN;
end

Lk = sum(Lk, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LxN1 = Lx(1:n*(N-1),:);
LuN1 = Lu(1:n*(N-1), 1:m*(N-1));
LdN1 = Ld(1:n*(N-1), 1:p*(N-1));
LkN1 = Lk(1:n*(N-1),:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Create poly constraints %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add input constraints
LU = dyn.XU_set.A;
lU = dyn.XU_set.b;

LU_x = LU(:,1:n);
LU_u = LU(:,n+1:n+m);

dLU_x = kron(eye(N-1), LU_x);
dLU_u = kron(eye(N-1), LU_u);
dlU = repmat(lU,N-1,1);

A_u_X = [ LU_x; 
          dLU_x*LxN1];

A_u_U = [ LU_u zeros(size(LU_u,1), m*(N-1)); 
          [dLU_x*LuN1 zeros(size(dLU_u,1),m)]+[zeros(size(dLU_u,1),m) dLU_u] ];
A_u = [A_u_X A_u_U];

b_u = [lU; 
       dlU-dLU_x*LkN1];

% Add state con.constraints, x(i) \in poly(i)(perm(i)) for all i
diagA = kron(eye(N),Hx);
diagb = repmat(hx,N,1);

if p>0
    XD_plus_x = dyn.XD_plus(:,1:n);
    XD_plus_d = dyn.XD_plus(:,n+1);

    XD_minus_x = dyn.XD_minus(:,1:n);
    XD_minus_d = dyn.XD_minus(:,n+1);

    Ld_0 = Ld(:,1:p); % part of Ld acting on d(0) - only disturbance we care about

    HH = [A_u; 
          diagA*Lx+diagA*Ld_0*XD_plus_x  diagA*Lu;
          diagA*Lx+diagA*Ld_0*XD_minus_x diagA*Lu];
    hh = [b_u ;
          diagb-diagA*Lk-diagA*Ld_0*XD_plus_d;
          diagb-diagA*Lk-diagA*Ld_0*XD_minus_d];  
else
	HH = [A_u; 
		  diagA*Lx 	diagA*Lu];
	hh = [b_u ;
		  diagb-diagA*Lk];	
end

A_ineq = HH(:,n+1:n+N*m);
b_ineq = hh - HH(:,1:n)*x0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create QP costs %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

H = Ru + Lu'*Rx*Lu;
f = ru + Lu'*Rx*(Lx*x0+Lk)+Lu'*rx;

u0 = quadprog(H,f,A_ineq, b_ineq)

u0/dyn.get_constant('B_cond_number') + con.f2*(v - con.lin_speed)^2

