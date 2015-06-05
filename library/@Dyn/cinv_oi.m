function [V] = cinv_oi(dyn, R, maxiter, show_plot, verbose)
	
	% CINV_OI: Compute an invariant set outside-in.
	% ======================================================
	%
	% SYNTAX
	% ------
	%	C = cinv_oi(dyn, R)
	%	C = cinv_oi(dyn, R, maxiter)
	%	C = cinv_oi(dyn, R, maxiter, show_plot, verbose)
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
	%	show_plot 	Show plotting while computing
	%		Default: false
	%	verbose 	Output text
	%		Default: false

	if nargin<3
		maxiter = Inf;
	end

	if nargin<4
		show_plot = 0;
	end

	if nargin<5
		verbose = 0;
	end

	disp('Finding controlled-invariant set by outside-in')
	tic 

	V = R;
	i = 1;
	tic;
	while (i <= maxiter)
		V_prim = intersect1(R, dyn.pre(V));

		if show_plot
			plot(V_prim);
			drawnow;
		end

		if isEmptySet(mldivide(V, V_prim))
			break;
		end

		V = V_prim;
		if verbose
			disp(['iteration ', num2str(i)])
		end
		i = i+1;
	end
	time = toc;
	disp(['Outside-in controlled-invariant set algo finished in ', num2str(time), ' seconds after ', num2str(i), ' iterations'])
end