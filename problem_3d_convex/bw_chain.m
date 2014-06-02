function C_vec = bw_chain(pwddyn, winning, safe)

	disp('Looking for a backwards chain')
	C_vec = [winning];
	iter = 0;
	while true
		disp(['iteration: ' num2str(iter)])
		pre = pwddyn.solve_feasible(C_vec(end), 1);
		pre = intersect1(safe, pre);
		if isa(pre, 'PolyUnion')
			pre2 = find_max(pre);
		else
			pre2 = pre;
		end
		plot(mldivide1(pre,pre2));

		axis([0 35 0 300 0 35])
		drawnow
		pause(1)

		if C_vec(end).contains(pre2)
			break
		end
		C_vec(end+1) = pre2;
		iter = iter+1;
	end
end

