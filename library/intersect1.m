function [ isect ] = intersect1( poly1, poly2 )

	if isa(poly1, 'PolyUnion')
		isect = PolyUnion;
		for i=1:poly1.Num
			isect = add1(isect, intersect1(poly1.Set(i), poly2));
		end
		return;
	end

	if isa(poly2, 'PolyUnion')
		isect = PolyUnion;
		for i=1:poly2.Num
			isect = add1(isect, intersect1(poly2.Set(i), poly1));
		end
		return;	
	end

	isect = Polyhedron('H', [poly1.H; poly2.H]);
	isect.minHRep();
	return;
end