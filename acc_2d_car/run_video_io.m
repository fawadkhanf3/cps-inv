maxiter = 30;

con = constants_cdc2014;
dyn_model = get_2d_dyn(con);

%% define V-H State space
VH = Polyhedron([eye(2); -eye(2)], [con.v_max; con.h_max; -con.v_min; -con.h_min]);

%% Define safe set
safe = intersect1(VH, Polyhedron('A', [con.tau_min -1; 0 -1], 'b', [0; -con.h_safe]));

%% Define goal set
goal = intersect1(safe, Polyhedron('A', [con.tau_des  -1; 1 0], 'b', [0; con.v_des]));

C0 = intersect1(goal, Polyhedron([1 0; -1 0], [con.v_lead; -con.v_lead])); 

vidObj = VideoWriter('inside_out.mp4', 'MPEG-4');
vidObj.FrameRate = 3;
open(vidObj);

clf; hold on;
plot(intersect1(Polyhedron([ 0 1], [300]), goal), 'alpha', 0.3, 'color', 'red')
plot(intersect1(Polyhedron([ 0 1], [300]), C0), 'alpha', 0.3, 'color', 'red')
xlim([0 35])
ylim([0 300])
set(gcf,'color','w');
axis off	
currFrame = getframe(gca, [0 0 430 344]);
writeVideo(vidObj, currFrame);


C_iter = C0;

iter = 2;
while iter<=maxiter
	C = intersect1(goal, dyn_model.pre(C_iter));
	
	removed = mldivide(C, C_iter);
	if removed.isEmptySet
		break;
	end

	C_iter = C;

	clf; hold on
	plot(intersect1(Polyhedron([ 0 1], [300]), goal), 'alpha', 0.3, 'color', 'red')
	plot(intersect1(Polyhedron([ 0 1], [300]), C_iter), 'color', [0 1 0])
	xlim([0 35])
	ylim([0 300])
	set(gcf,'color','w');
	axis off
	currFrame = getframe(gca, [0 0 430 344]);
	writeVideo(vidObj, currFrame);

	iter=iter+1
end
C_iter

close(vidObj)

% cinv = robust_cinv(dyn_model, goal); 
% set_chain = bw_chain(dyn_model, cinv, S1);
% simulate_3d(pwddyn, chain);

%% Plot stuff
% figure(1)
% clf
% hold on
% plot(intersect1(Polyhedron([ 0 1 0], [200]), cinv), 'alpha', 0.3, 'color', 'green')
% xlabel('$v$')
% ylabel('$h$'); ylim([-5 200])
% zlabel('$v_L$')

% matlab2tikz('invariant_set.tikz','interpretTickLabelsAsTex',true, 'width','\figurewidth', 'height', '\figureheight', 'parseStrings',false, 'showInfo', false)