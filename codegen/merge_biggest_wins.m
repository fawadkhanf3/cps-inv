function newpoly = merge_biggest_wins(poly1, poly2)

	sol = poly1.extreme([0 0 1]');
	x3max1 = sol.supp;
	sol = poly1.extreme([0 0 -1]);
	x3min1 = sol.supp;

	sol = poly2.extreme([0 0 1]');
	x3max2 = sol.supp;
	sol = poly2.extreme([0 0 -1]);
	x3min2 = sol.supp;

	if x3max2 - x3min2 > x3max1 - x3min1
		bigP = poly1;
		smaP = poly2;
	else
		smaP = poly1;
		bigP = poly2;
	end

	[common, index, ~] = isAdjacent(bigP,smaP);

	newH = bigP.H(setdiff(1:size(bigP.H, 1), index), :);

	for i = 1:size(smaP.H, 1)
		sol = bigP.extreme(smaP.A(i,:)); % maximize in direction of new facet
		ximax = sol.supp;
		if ximax < smaP.b(i)
			newH = [newH; smaP.H(i,:)];
		end
	end

	newpoly = Polyhedron('H', newH);
end