con = constants;

plot_and_video = 1;

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


if plot_and_video
	% initialize video object
	poly10 = Polyhedron([ 0 1 0], [10]);
	f = figure;
	plot(intersect1(goal, poly10),  'color', 'green', 'alpha', 0.2)
	% axis off
	set(gcf,'color','w');
end

%%%% Step 1: compute inner cinv set

Ci = goal;

while (true)
	Ci_1 = intersect1(goal, dyn.pre(Ci));

	if plot_and_video
		clf; hold on
		plot(intersect1(Ci, poly10), 'color', 'green', 'alpha', 0.2)
		% axis off
	end

	if isEmptySet(mldivide(Ci, Ci_1))
		break;
	end

	Ci = Ci_1;
end

C0 = Ci;

%%%% Step 2: expand inner cinv set
Cinv_vec = [C0];

while true
	Ci = intersect1(goal, pwadyn.pre(Cinv_vec(end)));
	Ci_cvx = merge_in(Ci.Set(2), Ci.Set(1));
	Ci_cvx = merge_in(Ci_cvx, Ci.Set(3));

	if isEmptySet(mldivide(Ci_cvx, Cinv_vec(end)))
		break;
	end

	if plot_and_video
		figure(f); hold on
		plot(intersect1(Ci_cvx, poly10), 'color', 'green', 'alpha', 0.2)
	end

	Cinv_vec = [Cinv_vec; Ci_cvx];
end


%%%% Step 3: expand Cinv_vec in domain

set_mat = {Cinv_vec};

for t=1:10
	Ct_vec = [];

	for i=1:length(set_mat{end})
		Ci = intersect1(S1, pwadyn.pre(set_mat{end}(i)));
		Ci_cvx = merge_in(Ci.Set(2), Ci.Set(1));
		Ci_cvx = merge_in(Ci_cvx, Ci.Set(3));
		Ct_vec = [Ct_vec Ci_cvx];
	end

	if plot_and_video
		figure(f); hold on
		plot(intersect1(Ci_cvx, poly10), 'color', 'green', 'alpha', 0.2)
	end

	set_mat = [set_mat {Ct_vec}];
end

save('simulation/set_mat.mat', 'set_mat', 'S1', 'goal')