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