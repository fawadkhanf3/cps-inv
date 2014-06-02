function [V] = cinv_oi(dyn, R, show_plot, rel_tol, verbose)
	
	%
	%  Tries to make the region R controlled-invariant with
	%  respect to the dynamics dyn, by successively shrinking
	%  the set
	%

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
		disp(['1, Number of polys: ', ...
			num2str(V_prim.Num), ', Voldiff: ', num2str(rel_vol)])
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
			disp([num2str(i), ', Number of polys: ', ...
				num2str(V_prim.Num), ', Voldiff: ', num2str(rel_vol)])
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

