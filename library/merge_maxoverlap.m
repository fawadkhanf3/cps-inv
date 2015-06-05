function [newpoly] = merge_maxoverlap(poly1, poly2)

    % merge_maxoverlap: Merge poly1 in poly2 as to create a maximal overlap
    % ======================================================
    %
    % SYNTAX
    % ------
    %   newpoly = pre(poly1, poly2)
    %
    %
    % INPUT
    % -----
    %   poly1, poly2    Explanation
    %           Class: Polyhedron
    % OUTPUT
    % -----
    %   newpoly    Explanation
    %           Class: Polyhedron

	ha = HypArr(PolyUnion([poly1, poly2]), 1);
	mark1 = ha.get_marking_poly(poly1);
	wm = white_markings(ha, PolyUnion([poly2]));

	new = mark1;
	zeroinds = find(mark1 == 0);

	for i=1:size(wm, 1)

		inds = find(mark1 == -wm(i,:));

		if length(inds) ~= 1
			continue; % exactly 1 hp should differ
		end

		% check that 0-hp's in mark1 dont cause trouble
		ok_flip = true;
		for j=zeroinds
			flip = wm(i,:);
			flip(j) = -flip(j);
			if isFullDim(ha.get_poly(flip))
				ok_flip = false;
				break;
			end
		end
		
		if ok_flip
			new(inds) = 0;
		end
	end

	newpoly = ha.get_poly(new);

end