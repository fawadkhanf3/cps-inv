function ret = pre_pwa_cinvtarget(pwadyn, goal, container)

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

    plot = 1;
	
    ret = goal;

	i = 0;
	while true

		C1 = intersect(pwadyn.reg_list{1}, pwadyn.dyn_list{1}.pre(ret));
		C2 = intersect(pwadyn.reg_list{2}, pwadyn.dyn_list{2}.pre(ret));
		C3 = intersect(pwadyn.reg_list{3}, pwadyn.dyn_list{3}.pre(ret));

		Ci_cvx = C2;
		Ci_cvx = merge_in(Ci_cvx, C1);
		Ci_cvx = merge_in(Ci_cvx, C3);

		Ci_cvx = intersect(Ci_cvx, container);

		if plot 
			% plot(ret, 'alpha', 0.2);
			drawnow;
		end

		if isEmptySet(mldivide(Ci_cvx, ret))
			break;
		end

		ret = Ci_cvx;

		i = i+1;
	end

end
