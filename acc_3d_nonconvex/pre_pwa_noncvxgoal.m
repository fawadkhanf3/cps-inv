function pre_list = pre_pwa_noncvxgoal(pwadyn, goal, container)

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
	
	pre_list = {goal};
	i = 0;
	while true

		disp(['iteration ', num2str(i)]);
		Ct_vec = [];
		new = 0;

		for j=1:length(pre_list{end})
			C1 = intersect(pwadyn.reg_list{1}, pwadyn.dyn_list{1}.pre(pre_list{end}(j) ));
			C2 = intersect(pwadyn.reg_list{2}, pwadyn.dyn_list{2}.pre(pre_list{end}(j) ));
			C3 = intersect(pwadyn.reg_list{3}, pwadyn.dyn_list{3}.pre(pre_list{end}(j) ));
			Ci_cvx = C2;
			Ci_cvx = merge_in(Ci_cvx, C1);
			Ci_cvx = merge_in(Ci_cvx, C3);

			Ci_cvx = intersect(Ci_cvx, container);

			if ~isEmptySet(mldivide(Ci_cvx, pre_list{end}(j) ))
				new = 1;
			end

			Ct_vec = [Ct_vec Ci_cvx];
		end

		if ~new
			break;
		end

		pre_list = [pre_list; {Ct_vec}];
		i = i+1;
	end

end
