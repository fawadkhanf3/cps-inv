function [V] = cinv_oi(dyn, R, show_plot, rel_tol, verbose)
	
	% CINV_OI: Compute an invariant set outside-in.
	% ======================================================
	%
	% SYNTAX
	% ------
	%	C = cinv_oi(dyn, R)
	%	C = cinv_oi(dyn, R, show_plot, rel_tol, verbose)
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
	%	show_plot 	Show plotting while computing
	%		Default: false
	%	rel_tol 	Volume stopping criterion
	%		Default: 1e-3
	%	verbose 	Output text
	%		Default: false

	if nargin<3
		show_plot=0;
	end

	if nargin<4
		rel_tol = 1e-3;
	end

	if nargin<5
		verbose = 0;
	end

	disp('Finding controlled-invariant set by outside-in')
	tic 

	V = R;
	V_prim = intersect1(V, dyn.solve_feasible(V,1,1));
	V_prim = merge1(V_prim,3,0);

	vol1 = volume1(V);
	vol2 = volume1(V_prim);
	rel_vol = (vol1-vol2)/vol1;

	if verbose
		message(1, V_prim, rel_vol)
	end

	i = 2;
	while rel_vol > rel_tol
		V = V_prim;
		V_prim = intersect1(V, dyn.solve_feasible(V,1,1));
		V_prim = merge1(V_prim,3,0);

		vol1 = volume1(V);
		vol2 = volume1(V_prim);
		rel_vol = (vol1-vol2)/vol1;
		if verbose
			message(i, V_prim, rel_vol);
		end
		i = i+1;
		if show_plot
			plot(V_prim);
			drawnow;
		end
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

