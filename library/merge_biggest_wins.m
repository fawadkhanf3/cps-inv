function newpoly = merge_biggest_wins(poly1, poly2, vol_dir)
	% MERGE_BIGGEST_WINS: Simple merging procedure for neighboring polyhedra.
	% ======================================================
	%
	% SYNTAX
	% ------
	%	U = merge_biggest_wins(P,Q)
	%	U = merge_biggest_wins(P,Q,vol_dir)
	%
	% DESCRIPTION
	% -----------
	%	Computes a convex polyhedron contained in the union of two 
	%   neighboring polyhedra
	%
	% INPUT
	% -----
	%	P,Q		Polyhedra representing the union
	%   dir 	Direction along which maximal polyhedron is determined
	% 			Default: normal direction of intersecting facet
	% 	

	[~, index1, index2] = isAdjacent(poly1,poly2);

	if nargin<3
		direction = poly1.A(index1,:);
	end

	sol = poly1.extreme(direction);
	x3max1 = sol.supp;
	sol = poly1.extreme(-direction);
	x3min1 = sol.supp;

	sol = poly2.extreme(direction);
	x3max2 = sol.supp;
	sol = poly2.extreme(-direction);
	x3min2 = sol.supp;

	if x3max2 - x3min2 > x3max1 - x3min1
		bigP = poly1;
		smaP = poly2;
		newH = bigP.H(setdiff(1:size(bigP.H, 1), index1), :);
	else
		smaP = poly1;
		bigP = poly2;
		newH = bigP.H(setdiff(1:size(bigP.H, 1), index), :);
	end

	for i = 1:size(smaP.H, 1)
		sol = bigP.extreme(smaP.A(i,:)); % maximize in direction of new facet
		ximax = sol.supp;
		if ximax < smaP.b(i)
			newH = [newH; smaP.H(i,:)];
		end
	end

	newpoly = Polyhedron('H', newH);
end