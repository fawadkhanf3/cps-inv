function [inner, outer] = in_out_cinv(dyn, pwadyn, target, plot, maxiter)

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


    if nargin<4
    	plot = 0;
    end

    if nargin<5
    	maxiter = 100;
    end

    % inner approximation
	Ci = target;
	i = 0;

	if plot
		clf;
	end

	while i < maxiter
		disp(['iteration ', num2str(i)])

		Ci_1 = intersect1(target, dyn.pre(Ci));

		if plot
			plot(Ci_1, 'alpha', 0.2);
			drawnow;
		end

		if isEmptySet(mldivide(Ci, Ci_1))
			break;
		end

		Ci = Ci_1;
		i = i+1;
	end

	if i == maxiter
		outer = Polyhedron;
		inner = Polyhedron;
		return;
	end

	inner = Ci;
	
	outer = [inner];
	i = 0;

	if plot 
		clf; hold on
		plot(inner, 'alpha', 0.2)
		drawnow;
	end

	% expand it inside target
	while i < maxiter
		disp(['iteration ', num2str(i)])

		C1 = intersect(pwadyn.reg_list{1}, pwadyn.dyn_list{1}.pre(outer(end) ));
		C2 = intersect(pwadyn.reg_list{2}, pwadyn.dyn_list{2}.pre(outer(end) ));
		C3 = intersect(pwadyn.reg_list{3}, pwadyn.dyn_list{3}.pre(outer(end) ));

		Ci_cvx = C2;
		Ci_cvx = merge_in(Ci_cvx, C1);
		Ci_cvx = merge_in(Ci_cvx, C3);

		Ci_cvx = intersect(Ci_cvx, target);

		if plot 
			plot(Ci_cvx, 'alpha', 0.2);
			drawnow;
		end

		if isEmptySet(mldivide(Ci_cvx, outer(end)))
			break;
		end

		outer = [outer; Ci_cvx];
		i = i+1;
	end

end