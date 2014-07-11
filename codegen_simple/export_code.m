%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate C code %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

codegen -c -d 'matlab_c' -config:lib ...
	    qp_vars -args {zeros(n,1)} ...
	    kalman -args {zeros(3,1), zeros(3), zeros(2,1), zeros(1,1), 1} ...   
	    kalman_4d -args {zeros(4,1), zeros(4), zeros(2,1), zeros(1,1), 1}	 

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

% Compute number of inequalities in output
num_poly_hp_max = max(size(set0.A,1),size(set1.A,1));
num_xu_hp = size(XUA,1);
if p>0
	max_num_ineq = N*(num_xu_hp+2*num_poly_hp_max);
else
	max_num_ineq = N*(num_xu_hp+num_poly_hp_max);
end

fid = fopen('./definitions.h','wt');
fprintf(fid,'%s', '#define QP_N ');
fprintf(fid,'%d\n', N);
fprintf(fid,'%s', '#define QP_XDIM ');
fprintf(fid,'%d\n', n);
fprintf(fid,'%s', '#define QP_UDIM ');
fprintf(fid,'%d\n', m);
fprintf(fid,'%s', '#define QP_MAX_INEQ ');
fprintf(fid,'%d\n', max_num_ineq);


fprintf(fid,'%s', '#define KAL_XDIM ');
fprintf(fid,'%d\n', 4);
fprintf(fid,'%s', '#define KAL_YDIM ');
fprintf(fid,'%d\n', 2);

fclose(fid);
