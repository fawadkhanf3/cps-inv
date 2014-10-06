con = constants;
pwadyn = get_pw_dyn(con);
simple_dyn = get_simple_dyn(con);

VH = pwadyn.domain;
%Safe set
S1 = intersect(VH, Polyhedron([1 -1 0; 0 -1 0], [0; -3]));
% Goal set
GA = [con.h_des-con.h_delta -1 0; 1 0 0];
Gb = [0; con.v_des+con.v_delta];
goal = intersect1(S1, Polyhedron('A', GA, 'b', Gb));

maxiter = 56;
vidObj = VideoWriter('outside_in.mp4', 'MPEG-4');
vidObj.FrameRate = 10;
open(vidObj);

plot(intersect1(Polyhedron([ 0 1 0], [200]), goal), 'alpha', 0.3, 'color', 'blue')
axis off
view([70 8])
currFrame = getframe
writeVideo(vidObj, currFrame);

C_iter = goal;

iter = 2;
while iter<=maxiter
	C = intersect1(C_iter, pwadyn.solve_feasible(C_iter, 1));
	
	[merged, best] = merge1(C,1,1);
	[~, maxindex] = max(best);
	C_cvx = merged.Set(maxindex);

	removed = mldivide(C_iter, C_cvx);
	if removed.isEmptySet
		break;
	end

	C_iter = C_cvx;

	clf
	plot(intersect1(Polyhedron([ 0 1 0], [200]), C_iter), 'alpha', 0.3, 'color', 'blue')
	axis off
	view([70 8])
	currFrame = getframe;
	writeVideo(vidObj, currFrame);


	iter=iter+1
end
C_iter

close(vidObj)

% cinv = robust_cinv(pwadyn, goal); 
% set_chain = bw_chain(pwadyn, cinv, S1);
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