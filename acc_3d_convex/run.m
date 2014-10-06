con = constants;
pwa_dyn = get_dyn(con);

VH = pwa_dyn.domain;
%Safe set
S1 = intersect(VH, Polyhedron([1 -1 0; 0 -1 0], [0; -0.3]));

% Goal set
GA = [con.h_des-con.h_delta -1 0; 1 0 0];
Gb = [0; con.v_des+con.v_delta];
goal = intersect1(S1, Polyhedron('A', GA, 'b', Gb));

C = pwa_dyn.cinv_oi(goal, 40, 1e-3, true, true)

save('set_chain_save.mat', 'C')