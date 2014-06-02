function pu = mldivide1(pu1, pu2)

	if isa(pu1, 'PolyUnion')
		pu1 = pu1.Set;
	end
	if isa(pu2, 'PolyUnion')
		pu2 = pu2.Set;
	end

	pu = PolyUnion(mldivide(pu1, pu2));

end