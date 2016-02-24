function pre_list = pre_pwa(pwadyn, goal, container, plotstuff, maxiter, vidObj)

    % pre_pwa: short description
    % ======================================================
    %
    % SYNTAX
    % ------
    %   pre_list = pre(pwdyn, goal)
    %
    % DESCRIPTION
    % -----------
    %  description
    %
    % INPUT
    % -----
    %   pwdyn, goal    Explanation
    %           Class: Dyn
    % OUTPUT
    % -----
    %   pre_list    Explanation
    %           Class: Dyn

    if nargin<4
	    plotstuff = 0;
	end

	if nargin<5
		maxiter = 100;
	end

	if nargin<6
		vidObj = 0
	end

	if vidObj ~= 0
		isect_poly = Polyhedron([ 0 1 0], [200])
	end

	pre_list = [goal];
	i = 0;
	while i < maxiter

		disp(['iteration ', num2str(i)])

		C1 = intersect(pwadyn.reg_list{1}, pwadyn.dyn_list{1}.pre(pre_list(end) ));
		C2 = intersect(pwadyn.reg_list{2}, pwadyn.dyn_list{2}.pre(pre_list(end) ));
		C3 = intersect(pwadyn.reg_list{3}, pwadyn.dyn_list{3}.pre(pre_list(end) ));

		Ci_cvx = C2;
		if ~isEmptySet(C1)
			Ci_cvx = merge_in(Ci_cvx, C1);
		end
		if ~isEmptySet(C3)
			Ci_cvx = merge_in(Ci_cvx, C3);
		end

		Ci_cvx = intersect(Ci_cvx, container);

		if plotstuff 
			plot(Ci_cvx, 'alpha', 0.2);
			drawnow;
		end

		if vidObj ~= 0
			clf
			plot(intersect(Ci_cvx, isect_poly), 'color', 'red', 'alpha', 0.2)
			set(gcf,'color','w');
			axis off
			currFrame = getframe(gca, [0 0 430 344]);
			writeVideo(vidObj, currFrame);
		end

		if isEmptySet(mldivide(Ci_cvx, pre_list(end)))
			break;
		end

		pre_list = [pre_list; Ci_cvx];
		i = i+1;
	end

end
