con = constants;
pwddyn = get_pw_dyn(con);

VH = pwddyn.domain;

%Safe set
S1 = intersect(VH, Polyhedron([1 -1 0], [0]));

% Goal set
GA = [h_des-h_delta -1 0;
	   1  			  0 0];
Gb = [0;
	   v_des+v_delta];
goal = intersect1(VH, Polyhedron('A', GA, 'b', Gb));

% cinv = robust_cinv(pwddyn, goal);
% chain = bw_chain(pwddyn, cinv, S1);
simulate_3d(pwddyn, chain);