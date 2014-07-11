con = constants;
pwdyn = get_pw_dyn(con);

%%%%%%%%%%%% SYNTHESIZE %%%%%%%%%%%%%%

VH = pwdyn.domain;

%Safe set
S1 = intersect(VH, Polyhedron([con.h_min -1 0; 0 -1 0], [0; -0.2]));

% Goal set
GA = [con.h_des-con.h_delta -1 0; 1 0 0];
Gb = [0; con.v_des+con.v_delta];
goal = intersect1(S1, Polyhedron('A', GA, 'b', Gb));

set0 = pwdyn.cinv_oi(goal); 
pre = pwdyn.pre(set0);
set1 = pre.Set(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% SAVE STUFF TO MAT FILES %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = set0.A;
b = set0.b;
save('poly0_data.mat', 'A', 'b');

A = set1.A;
b = set1.b;
save('poly1_data.mat', 'A', 'b');

A = pwdyn.dyn_list{1}.A;
B = pwdyn.dyn_list{1}.B;
E = pwdyn.dyn_list{1}.E;
K = pwdyn.dyn_list{1}.K;
XUA = pwdyn.dyn_list{1}.XU_set.A;
XUb = pwdyn.dyn_list{1}.XU_set.b;
XD_plus = pwdyn.dyn_list{1}.XD_plus;
XD_minus = pwdyn.dyn_list{1}.XD_minus;
domainA = pwdyn.reg_list{1}.A;
domainb = pwdyn.reg_list{1}.b;

save('dyn1_data.mat', 'A', 'B', 'E', 'K', 'XUA', 'XUb', ...
	 'XD_plus', 'XD_minus', 'domainA', 'domainb')

A = pwdyn.dyn_list{2}.A;
B = pwdyn.dyn_list{2}.B;
E = pwdyn.dyn_list{2}.E;
K = pwdyn.dyn_list{2}.K;
XUA = pwdyn.dyn_list{2}.XU_set.A;
XUb = pwdyn.dyn_list{2}.XU_set.b;
XD_plus = pwdyn.dyn_list{2}.XD_plus;
XD_minus = pwdyn.dyn_list{2}.XD_minus;
domainA = pwdyn.reg_list{2}.A;
domainb = pwdyn.reg_list{2}.b;

save('dyn2_data.mat', 'A', 'B', 'E', 'K', 'XUA', 'XUb', ...
	 'XD_plus', 'XD_minus', 'domainA', 'domainb')

A = pwdyn.dyn_list{3}.A;
B = pwdyn.dyn_list{3}.B;
E = pwdyn.dyn_list{3}.E;
K = pwdyn.dyn_list{3}.K;
XUA = pwdyn.dyn_list{3}.XU_set.A;
XUb = pwdyn.dyn_list{3}.XU_set.b;
XD_plus = pwdyn.dyn_list{3}.XD_plus;
XD_minus = pwdyn.dyn_list{3}.XD_minus;
domainA = pwdyn.reg_list{3}.A;
domainb = pwdyn.reg_list{3}.b;

save('dyn3_data.mat', 'A', 'B', 'E', 'K', 'XUA', 'XUb', ...
	 'XD_plus', 'XD_minus', 'domainA', 'domainb')


scale_factor = pwdyn.dyn_list{2}.get_constant('B_cond_number');
f0 = con.f0;
f1 = con.f1;
f2 = con.f2;
f0_bar = con.f0;
f1_bar = con.f1;
mass = con.mass;
v_des = con.v_des;
h_des = con.h_des;
N = con.N;

save('constants.mat', 'N', 'scale_factor', 'f0', 'f1', 'f2', 'f0_bar',  ...
	 'f1_bar', 'v_des', 'h_des', 'mass')
