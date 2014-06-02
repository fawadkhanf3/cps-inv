function ret = contains1(pu, x0)

	if isa(pu, 'Polyhedron')
		ret = pu.contains(x0);
		return;
	end

	ret = 0;
	for i=1:length(pu.Set)
		if pu.Set(i).contains(x0)
			ret = 1;
			return
		end
	end
end