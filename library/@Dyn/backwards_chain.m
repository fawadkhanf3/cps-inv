function vp = backwards_chain(dyn, V, X_safe, show_plot, rel_tol, verbose)
	%
	%  Starts with the set V and finds a chan of sets 
	%  V_n -> V_{n-1} -> ... > V_1 > V
	%  such that each set is reachable from the set to 
	%  left. 
	%  
	%  All sets are intersected with X_safe.
	%

	if nargin<4
		show_plot = 0;
	end

	if nargin<5
		rel_tol = 1e-3;
	end

	if nargin<6
		verbose = 0;
	end

	disp('Finding backward-time control chain...')
	tic

	C_prim = V;
	vp = [];
	
	rel_vol = 1;
	i = 1;
	while rel_vol > 1e-3
		C = C_prim;
		vp = [vp, C];

		C_prim = intersect1(X_safe, dyn.solve_feasible(C,1,0));
		C_prim = merge1(C_prim,3,0);
		vol0 = volume1(C);
		vol1 = volume1(C_prim);
		rel_vol = abs((vol1-vol0) / vol0);

		if verbose
			disp([num2str(i), ', Number of polys: ', ...
				num2str(C_prim.Num), ', Voldiff: ', num2str(rel_vol)])
		end

		if show_plot
			plot(C_prim)
			drawnow
		end
		
		i = i+1;
	end

	time = toc;
	disp(['Finished backward-time control chain algo in ', num2str(time), ' seconds'])
end