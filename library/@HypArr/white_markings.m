function markings = white_markings(ha, polyunion)
	markings = zeros(0, ha.Num);
	for poly_num = 1:polyunion.Num
		polymark = ha.get_marking_poly(polyunion.Set(poly_num));
		new_markings = enumerate(ha, polymark);
		markings = [markings; new_markings];
	end
end