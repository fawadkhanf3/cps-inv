clear all, clf
con = constants;

plot_and_video = 1;

%%%% Create dynamics

dyn = get_dyn1(con);
pwadyn = get_dyn2(con);


%%%% Specify specification sets

%Safe set
VH = pwadyn.domain;
S1 = intersect(VH, Polyhedron([con.tau_min -1 0], [0]));

% Goal set lower
GA = [con.tau_des_min -1 0; 1 0 0];
Gb = [0; con.v_des_max];
goal_lower = intersect1(S1, Polyhedron('A', GA, 'b', Gb));

% Goal set upper
GA = [-con.tau_des_max 1 0; -1 0 0];
Gb = [0; con.v_des_max];
goal_upper = intersect1(VH, Polyhedron('A', GA, 'b', Gb));



poly50 = Polyhedron([ 0 1 0; 0 -1 0], [50; 0]);

%%%%%%%%% DO UPPER INV SET %%%%%%%%%%%%%

goal = goal_upper

%%%% Step 1: compute inner cinv set
Ci = goal;

while (true)
	Ci_1 = intersect1(goal, dyn.pre(Ci));

	if plot_and_video
		plot(intersect1(Ci, poly50), 'color', 'green', 'alpha', 0.2)
		drawnow
	end

	if isEmptySet(mldivide(Ci, Ci_1))
		break;
	end

	Ci = Ci_1;
	i = i+1;
end

C0 = Ci;

clf; hold on;

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
		plot(intersect1(Ci_cvx, poly50), 'color', 'green', 'alpha', 0.2)
		drawnow
	end

	Cinv_vec = [Cinv_vec; Ci_cvx];
end
Cinv_upper = Cinv_vec;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% DO LOWER INV SET %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% goal = intersect1(goal_lower, goal_upper);
goal = goal_lower

%%%% Step 1: compute inner cinv set

Ci = goal;

while (true)
	Ci_1 = intersect1(goal, dyn.pre(Ci));

	if plot_and_video
		plot(intersect1(Ci, poly50), 'color', 'green', 'alpha', 0.2)
		drawnow
	end

	if isEmptySet(mldivide(Ci, Ci_1))
		break;
	end

	Ci = Ci_1;
	i = i+1;
end

C0 = Ci;

clf; hold on;

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
		plot(intersect1(Ci_cvx, poly50), 'color', 'green', 'alpha', 0.2)
		drawnow
	end

	Cinv_vec = [Cinv_vec; Ci_cvx];
end
Cinv_lower = Cinv_vec;

clf; hold on;

for i=1:length(Cinv_upper)
	plot(intersect(poly50, Cinv_upper(i)), 'color', 'green', 'alpha', 0.2);
end

for i=1:length(Cinv_lower)
	plot(intersect(poly50, Cinv_lower(i)), 'color', 'blue', 'alpha', 0.05);
end

save('simulation/Cinv_lower.mat', 'Cinv_lower')
save('simulation/Cinv_upper.mat', 'Cinv_upper')

% %%%% Step 3: expand Cinv_vec in domain

% set_mat = {Cinv_vec};

% for t=1:6
% 	Ct_vec = [];

% 	for i=1:length(set_mat{end})
% 		Ci = intersect1(S1, pwadyn.pre(set_mat{end}(i)));
% 		Ci_cvx = merge_in(Ci.Set(2), Ci.Set(1));
% 		Ci_cvx = merge_in(Ci_cvx, Ci.Set(3));
% 		Ct_vec = [Ct_vec Ci_cvx];
% 	end

% 	if plot_and_video
% 		figure(f); hold on
% 		plot(intersect1(Ci_cvx, poly200), 'color', 'green', 'alpha', 0.2)
% 		currFrame = getframe(gcf);
% 		writeVideo(vidObj, currFrame);
% 	end

% 	set_mat = [set_mat {Ct_vec}];
% end

% if plot_and_video
% 	[az el] = view;
% 	for azt = az:10:150
% 		view([azt el])
% 		currFrame = getframe(gcf);
% 		writeVideo(vidObj, currFrame);
% 	end
% 	close(vidObj)
% end

% save('simulation/set_mat.mat', 'set_mat', 'S1', 'goal')