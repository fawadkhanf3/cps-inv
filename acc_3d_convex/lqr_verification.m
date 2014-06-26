con = constants;

% Continuous-time model:

A = [ -con.f1_bar/con.mass 0;
		-1 0 ];
B = [1/con.mass; 0];
C = eye(2);
D = zeros(2,1);

umax = con.umax - con.f0_bar;
umin = con.umin - con.f0_bar;

sys = ss(A,B,C,D);

Q = 1000*[1.4^2 -1.4;
 -1.4 1];
R = 1;

[K,S,E] = lqr(sys,Q,R);

A_cl = [A-B*K [0; 1]; 
        0 0 0];
B_cl = [0;0;0];
E_cl = [0;0;1];

% integrate closed-loop dynamics

A_s = @(s) expm(s*A_cl);
Ad = A_s(con.dT);
Bd = integral(A_s, 0, con.dT, 'ArrayValued', true) * B_cl;
Kd = zeros(3,1);
Ed = integral(A_s, 0, con.dT, 'ArrayValued', true) * E_cl;

XU_set = Polyhedron('Ae', [0 0 0 1], 'be', [0]);

kappa = con.f1_bar/con.mass;
ekt = exp(-kappa*con.dT);

plus_constant = (con.d_max_ratio/con.dT)*((1-ekt)*con.umax+con.f0_bar*(ekt-1))/con.f1_bar;
v_plus_coef = (con.d_max_ratio/con.dT)*(ekt-1);
v_plus_co = (con.v_l_max-con.dT*plus_constant)/(con.dT*v_plus_coef+1);

min_constant = (con.d_max_ratio/con.dT)*((1-ekt)*con.umin+con.f0_bar*(ekt-1))/con.f1_bar;
v_min_coef = (con.d_max_ratio/con.dT)*(ekt-1);
v_min_co = (con.v_l_min-con.dT*min_constant)/(con.dT*v_min_coef+1);

% Limitations on disturbance
XD_plus_mid = [ 0 0 v_plus_coef plus_constant ];
XD_minus_mid = [ 0 0 v_min_coef min_constant ];

XD_minus_low = [0 0 -1/con.dT con.v_l_min/con.dT];
XD_plus_high = [0 0 -1/con.dT con.v_l_max/con.dT];

region = Polyhedron([diag([1 0 1]); -diag([1 0 1])], [con.v_f_max; con.d_max; con.v_l_max; -con.v_f_min; -con.d_min; -con.v_l_min]);
reg1 = intersect(region, Polyhedron([0 0 1], [v_min_co]));
reg2 = intersect(region, Polyhedron([0 0 1; 0 0 -1], [v_plus_co; -v_min_co]));
reg3 = intersect(region, Polyhedron([0 0 -1], [-v_plus_co]));

dyn1 = Dyn(Ad,Bd,Kd,Ed,XU_set,XD_plus_mid,XD_minus_low);
dyn2 = Dyn(Ad,Bd,Kd,Ed,XU_set,XD_plus_mid,XD_minus_mid);
dyn3 = Dyn(Ad,Bd,Kd,Ed,XU_set,XD_plus_high,XD_minus_mid);

reg_list = {reg1, reg2, reg3};
dyn_list = {dyn1, dyn2, dyn3};

pwd = PwDyn(region, reg_list, dyn_list);

load set_chain_save;
Cinv = intersect1(set_chain(1), Polyhedron([0 1 0], [300]));

pre = pwd.solve_feasible(Cinv);

plot(intersect1(Cinv, pre.Set(2)), 'alpha', 0.8, 'color', 'blue')
hold on
plot(Cinv, 'alpha', 0.1, 'color', 'red')