function pre_mod = pre_removelims(dyn, X, dim, dim_min, dim_max)

	X.normalize;
	H = X.H;

	search_max = zeros(1,size(H,2));
	search_max(1,dim) = 1;
	search_max(1,end) = dim_max;

	search_min = zeros(1,size(H,2));
	search_min(1,dim) = -1;
	search_min(1,end) = -dim_min;

	H(ismember(H, search_max, 'rows'), :) = [];
	H(ismember(H, search_min, 'rows'), :) = [];

	pre_mod = dyn.solve_feasible(Polyhedron('H', H), 1, 1);
	pre_mod = intersect1(pre_mod, Polyhedron('H', [search_min; search_max]));

end