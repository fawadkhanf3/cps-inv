function [V] = cinv_oi(dyn, R, maxiter, rel_tol, show_plot, verbose)
	
	% CINV_OI: Compute an invariant set outside-in.
	% ======================================================
	%
	% SYNTAX
	% ------
	%	C = cinv_oi(dyn, R)
	%	C = cinv_oi(dyn, R, maxiter)
	%	C = cinv_oi(dyn, R, maxiter, rel_tol, show_plot, verbose)
	%
	% DESCRIPTION
	% -----------
	%	Computes the maximally controlled-invariant set contained in R
	%
	% INPUT
	% -----
	%	dyn	System dynamics
	% 		Class: Dyn
	%	R 	Dimensions upon which to project
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

	V = R;
	rel_vol = inf;
	i = 1;
	while (rel_vol > rel_tol) && (i <= maxiter)
		V_prim = intersect1(V, dyn.solve_feasible(V));
		V_prim = merge1(V_prim,3,0);

		v1 = volume1(V); v2 = volume1(V_prim);
		rel_vol = (v1-v2)/v1;
		
		if verbose
			message(i, V_prim, rel_vol);
		end
		if show_plot
			plot(V_prim);
			drawnow;
		end

		V = V_prim;
		i = i+1;
	end
	time = toc;
	disp(['Outside-in controlled-invariant set algo finished in ', num2str(time), ' seconds after ', num2str(i), ' iterations'])
end

function mes = message(i, V_prim, rel_vol)
	if isa(V_prim, 'Polyhedron')
		num = 1;
	else
		num = V_prim.Num;
	end
	disp([num2str(i), ', Number of polys: ', ...
		num2str(num), ', Voldiff: ', num2str(rel_vol)])
end

