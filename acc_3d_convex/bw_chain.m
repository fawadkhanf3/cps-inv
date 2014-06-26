function C_vec = bw_chain(pwddyn, winning, safe)

	disp('Looking for a backwards chain')
	C_vec = [winning];
	iter = 0;
	while iter<4
		disp(['iteration: ' num2str(iter)])
		pre = pwddyn.solve_feasible(C_vec(end), 1);
		pre = intersect1(safe, pre);
		if isa(pre, 'PolyUnion')
			% [merged, best] = merge1(pre,1,1);
			% [~, maxindex] = max(best);
			pre2 = pre.Set(2);
		else
			pre2 = pre.Set();
		end

		% if C_vec(end).contains(pre2)
		% 	break
		% end
		C_vec(end+1) = pre2;
		iter = iter+1;
	end
end

