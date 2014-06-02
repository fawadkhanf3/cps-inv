function [vol] = volume1(polyregion)
	if isa(polyregion, 'PolyUnion')
		no_region = remove_overlaps1(polyregion);
		vol = sum(volume(no_region.Set));
		return;
	end
	vol = polyregion.volume();
	return;
end