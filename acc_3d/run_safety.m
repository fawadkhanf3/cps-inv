case_nr = 1;

if case_nr == 1
	con = constants_normal;
elseif case_nr == 2
	con = constants_aggressive;
elseif case_nr == 3
	con = constants_normal_largevl;
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

if case_nr == 1
	save('supervisor/safe_set_normal.mat', 'safe_set');
	copyfile('constants_normal.m', 'supervisor/constants_normal.m')
elseif case_nr == 2
	save('supervisor/safe_set_aggressive.mat', 'safe_set');
	copyfile('constants_aggressive.m', 'supervisor/constants_aggressive.m')
elseif case_nr == 3
	save('supervisor/safe_set_normal_largevl.mat', 'safe_set');
	copyfile('constants_normal_largevl.m', 'supervisor/constants_normal_largevl.m')
end