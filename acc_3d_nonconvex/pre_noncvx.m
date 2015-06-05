function [inner, outer] = in_out_cinv(dyn1, dyn2, target)

    % in_out_cinv: find a non-convex controlled invariant set
    % ======================================================
    %
    % SYNTAX
    % ------
    %   inner, outer = pre(pwdyn, target)
    %
    % DESCRIPTION
    % -----------
    %  description
    %
    % INPUT
    % -----
    %   pwdyn, target    Explanation
    %           Class: Dyn
    % OUTPUT
    % -----
    %   inner, outer    Explanation
    %           Class: Dyn

    % inner approximation
	Ci = target;
	while (true)
		Ci_1 = intersect1(target, dyn1.pre(Ci));

		if isEmptySet(mldivide(Ci, Ci_1))
			break;
		end

		Ci = Ci_1;
		i = i+1;
	end

	inner = Ci;
	
	outer = [inner];

	% expand it inside target
	while true

		C1 = intersect(pwadyn.reg_list{1}, pwadyn.dyn_list{1}.pre(outer(end) );
		C2 = intersect(pwadyn.reg_list{2}, pwadyn.dyn_list{2}.pre(outer(end) );
		C3 = intersect(pwadyn.reg_list{3}, pwadyn.dyn_list{3}.pre(outer(end) );

		Ci_cvx = C2.
		Ci_cvx = merge_in(Ci_cvx, C1);
		Ci_cvx = merge_in(Ci_cvx, C3);

		if isEmptySet(mldivide(Ci_cvx, outer(end)))
			break;
		end

		outer = [outer; Ci_cvx];
	end

end