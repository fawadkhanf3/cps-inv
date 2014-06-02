function vols = volumes(ha, markings)
	vols = zeros(1, size(markings, 1));
	for i = 1:size(markings,1)
		vols(i) = volume(ha.get_poly(markings(i,:)));
	end
end