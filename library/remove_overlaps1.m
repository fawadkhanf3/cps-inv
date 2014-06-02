function [poly] = remove_overlaps1(pu)
	if pu.isOverlapping();
		reduce(pu);
		polyarray = pu.Set;

		new_list = [polyarray(1)];
		for i=2:length(polyarray)
			new_list = [new_list polyarray(i)\polyarray(1:i-1)];
		end
		poly = PolyUnion(new_list);
	else
		poly = pu;
	end
end
