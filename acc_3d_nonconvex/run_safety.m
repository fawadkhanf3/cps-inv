case_nr = 2;

if case_nr == 1
	con = constants_benign;
elseif case_nr == 2
	con = constants_aggressive;
end

plot_and_video = 1;

%%%% Create dynamics

dyn = get_dyn1(con);
pwadyn = get_dyn2(con);

%%%% Specify specification sets

%Safe set
VH = pwadyn.domain;
S = intersect(VH, Polyhedron([con.tau_min -1 0; 0 -1 0], [0; -con.h_min]));

[~, safe_set] = in_out_cinv(dyn, pwadyn, S);

save('supervisor/safe_set.mat', 'safe_set');

if case_nr == 1
	copyfile('constants_benign.m', 'supervisor/constants.m')
elseif case_nr == 2
	copyfile('constants_aggressive.m', 'supervisor/constants.m')
end