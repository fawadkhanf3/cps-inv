%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate C code %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = pwdyn.n;
m = pwdyn.m;
p = pwdyn.p;

codegen -c -d 'matlab_c' -config:lib ...
	    qp_vars -args {zeros(n,1)} ...
	    kalman -args {zeros(3,1), zeros(3), zeros(2,1), zeros(1,1), 1} ...   
	    kalman_4d -args {zeros(4,1), zeros(4), zeros(2,1), zeros(1,1), 1}	 

% Save some constants in a C-style header
num_poly_hp_max = max(size(set0.A,1),size(set1.A,1));
num_xu_hp = size(XUA,1);
if p>0
	max_num_ineq = N*(num_xu_hp+2*num_poly_hp_max);
else
	max_num_ineq = N*(num_xu_hp+num_poly_hp_max);
end

fid = fopen('./matlab_c/definitions.h','wt');
fprintf(fid,'%s', '#define V_LIN ');
fprintf(fid,'%f\n', con.lin_speed);
fprintf(fid,'%s', '#define CAR_MASS ');
fprintf(fid,'%f\n', con.mass);
fprintf(fid,'%s', '#define CAR_F0 ');
fprintf(fid,'%f\n', con.f0);
fprintf(fid,'%s', '#define CAR_F1 ');
fprintf(fid,'%f\n', con.f1);
fprintf(fid,'%s', '#define CAR_F2 ');
fprintf(fid,'%f\n', con.f2);

fprintf(fid,'%s', '#define QP_N ');
fprintf(fid,'%d\n', con.N);
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