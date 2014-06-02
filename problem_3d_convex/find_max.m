function maxpoly = find_max(polyunion)
% Find the largest polytope in the union, and extend it to form one convex polytope

	rads = extractfield(polyunion.Set.chebyCenter, 'r');
	[~, maxpolyind] = max(rads);
	maxpoly = polyunion.Set(maxpolyind);
	for i=1:length(rads)
		if i == maxpolyind
			continue
		end
		smaller_poly = polyunion.Set(i);
		maxpoly = merge_dumb(maxpoly, smaller_poly);
	end
end

function new_poly = merge_dumb(bigpoly, smallpoly)
	% Given two intersecting polyhedra bigpoly and smallpoly,
	% find their intersecting facet and extend bigpoly as much as possible inside smallpoly.
	bigpoly.normalize;
	bigpoly.minHRep;
	smallpoly.normalize;
	smallpoly.minHRep;
	H_big = bigpoly.H;
	H_small = smallpoly.H;
	[~, del_ind, ~] = intersect(H_big, -H_small, 'rows'); % find dividing plane
	new_H = H_big;
	new_H(del_ind, :) = [];
	for i=1:size(H_small, 1)
		testpoly = Polyhedron('H', -H_small(i,:));
		is = intersect(testpoly, bigpoly);
		if is.isEmptySet
			new_H(end+1, :) = H_small(i,:);
		end
	end
	new_poly = Polyhedron('H', new_H);
	new_poly.normalize;
	new_poly.minHRep;
end