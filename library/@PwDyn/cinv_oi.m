function [C_iter] = robust_cinv(pwdyn, goal, maxiter, rel_tol, show_plot, verbose)
	% CINV_OI: Compute an invariant set outside-in.
	% ======================================================
	%
	% SYNTAX
	% ------
	%	C = cinv_oi(pwdyn, R)
	%	C = cinv_oi(pwdyn, R, maxiter)
	%	C = cinv_oi(pwdyn, R, maxiter, rel_tol, show_plot, verbose)
	%
	% DESCRIPTION
	% -----------
	%	Computes the maximally controlled-invariant set contained in R
	%
	% INPUT
	% -----
	%	dyn	System dynamics
	% 		Class: Dyn
	%	R 	Goal set
	%		Class: Polyhedron or PolyUnion
	%   maxiter  Maximal number of iterations
	% 		Default: inf
	%	rel_tol 	Volume stopping criterion
	%		Default: 1e-3
	%	show_plot 	Show plotting while computing
	%		Default: false
	%	verbose 	Output text
	%		Default: false

	if nargin<3
		maxiter = Inf;
	end

	if nargin<4
		rel_tol = 1e-3;
	end

	if nargin<5
		show_plot = 0;
	end

	if nargin<6
		verbose = 0;
	end

	disp('Finding controlled-invariant set by outside-in')
	tic 

	C_iter = goal;

	iter = 0;
	while iter < maxiter
		disp(['iteration: ' num2str(iter)])
		C = intersect1(C_iter, pwdyn.solve_feasible(C_iter, 1));
		
		C_cvx = C.Set(1);
		for i=2:pwdyn.num_region
			C_cvx = merge_biggest_wins(C_cvx, C.Set(i));
		end

		removed = mldivide(C_iter, C_cvx);
		if removed.isEmptySet
			break;
		end

		C_iter = C_cvx;

		if show_plot
			plot(C_iter, 'alpha', 0.6, 'color', 'blue')
			drawnow
		end
		iter=iter+1;
	end

	time = toc;
	disp(['Outside-in controlled-invariant set algo finished in ', num2str(time), ' seconds after ', num2str(iter), ' iterations'])
end