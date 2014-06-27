function [C_iter] = robust_cinv(pwddyn, goal)

	C_iter = goal;
	disp('Looking for a robustly control-invariant set')

	iter = 0;
	while true
		disp(['iteration: ' num2str(iter)])
		C = intersect1(C_iter, pwddyn.solve_feasible(C_iter, 1));
		
		% [merged, best] = merge1(C,1,1);
		% [~, maxindex] = max(best);
		% C_cvx = merged.Set(maxindex);
		C_cvx = merge_biggest_wins(C.Set(1), C.Set(2));
		C_cvx = merge_biggest_wins(C_cvx, C.Set(3));

		removed = mldivide(C_iter, C_cvx);
		if removed.isEmptySet
			break;
		end

		C_iter = C_cvx;
		plot(C_iter)
		axis([0 5 0 10 0 5])
		drawnow
		pause(0.2)
		iter=iter+1;
	end
	C_iter
end