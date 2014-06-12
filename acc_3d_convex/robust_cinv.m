function [C_iter] = robust_cinv(pwddyn, goal)

	C_iter = goal;
	disp('Looking for a robustly control-invariant set')

	iter = 0;
	while true
		disp(['iteration: ' num2str(iter)])
		C = intersect1(C_iter, pwddyn.solve_feasible(C_iter, 1));
		
		[merged, best] = merge1(C,1,1);
		[~, maxindex] = max(best);
		C_cvx = merged.Set(maxindex);

		removed = mldivide(C_iter, C_cvx);
		if removed.isEmptySet
			break;
		end

		C_iter = C_cvx;
		plot(C_iter)
		axis([0 35 0 300 0 35])
		drawnow
		pause(1)
		iter=iter+1;
	end
	C_iter
end