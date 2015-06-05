max = Inv1small(end)
for i = length(Inv1small)-1:-1:1
	max = merge_maxoverlap(max, Inv1small(i))
end

