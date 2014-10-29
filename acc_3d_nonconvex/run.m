con = constants;

%%%% Create dynamics

dyn = get_dyn1(con);
pwadyn = get_dyn2(con);


%%%% Specify specification sets

%Safe set
VH = pwadyn.domain;
S1 = intersect(VH, Polyhedron([con.tau_min -1 0; 0 -1 0], [0; -con.h_min]));

% Goal set
GA = [con.tau_des -1 0; 1 0 0];
Gb = [0; con.v_des_max];
goal = intersect1(S1, Polyhedron('A', GA, 'b', Gb));


%%%% Step 1: compute inner cinv set

C0 = dyn.cinv_oi(goal);


%%%% Step 2: expand inner cinv set

Cinv_vec = [C0];

while true
	Ci = intersect1(goal, pwadyn.pre(Cinv_vec(end)));
	Ci_cvx = merge_in(Ci.Set(2), Ci.Set(1));
	Ci_cvx = merge_in(Ci_cvx, Ci.Set(3));

	if isEmptySet(mldivide(Ci_cvx, Cinv_vec(end)))
		break;
	end

	Cinv_vec = [Cinv_vec; Ci_cvx];
end


%%%% Step 3: expand Cinv_vec in domain

set_mat = {Cinv_vec};

for t=1:6
	Ct_vec = [];

	for i=1:length(set_mat{end})
		Ci = pwadyn.pre(set_mat{end}(i));
		Ci_cvx = merge_in(Ci.Set(2), Ci.Set(1));
		Ci_cvx = merge_in(Ci_cvx, Ci.Set(3));
		Ct_vec = [Ct_vec Ci_cvx];
	end

	set_mat = [set_mat {Ct_vec}];
end

save('simulation/set_mat.mat', 'set_mat')