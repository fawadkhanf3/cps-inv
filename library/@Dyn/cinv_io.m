function [V] = cinv_io(dyn, R, V, show_plot, verbose)

	if nargin < 4
		show_plot = 0;
	end

	if nargin < 5
		verbose = 0;
	end

	%
	%  Tries to find the maximal controlled-invariant set 
	%  contained in R by starting with a small controlled-
	%  invariant set V.
	%

	disp('Finding controlled-invariant set by inside-out')
	tic

	V_prim = intersect1(R, dyn.pre(V,1));

	rel_vol = 1;
	i = 0;
	while rel_vol > 1e-3
		V = V_prim;
		V_prim = intersect1(R, dyn.pre(V, 1));
		V_prim = merge1(V_prim,3,0);
		vol0 = volume1(V);
		vol1 = volume1(V_prim);

		rel_vol = abs((vol1-vol0) / vol0);
		if verbose
			disp([num2str(i), ', Number of polys: ', ...
				num2str(V_prim.Num), ', Voldiff: ', num2str(rel_vol)])
		end
		i = i+1;
		if show_plot
			plot(V_prim)
			drawnow
		end
	end
	time = toc;
	disp(['Inside-out controlled-invariant set algo finished in ', num2str(time), ' seconds after ', num2str(i), ' iterations'])
end