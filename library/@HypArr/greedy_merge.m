% DOES NOT WORK

function poly = greedy_merge(ha, whitemark)
	vols = ha.volumes(whitemark);
	[~, start_mark] = max(vols);
	remaining_marks = whitemark;

	maxpoly = whitemark(start_mark, :);
	remaining_marks(start_mark, :) = [];
	found = 1;
	while found
		found = 0;
		for i = 1:ha.Num
			if has_marks(maxpoly, remaining_marks, i)
				maxpoly(i) = 0;
				% remaining_marks(i, :) = [];
			end
		end
	end

	poly = ha.get_poly(maxpoly);
end

function env_mark = env(markings)
	% Get the marking of the envelope of `markings'
	[N_m, N_hp] = size(markings);
	env_mark = fix(sum(markings, 1)/N_m);
end

function found = has_marks(mark0, mark_col, changeind)
	% Check if _all_ the markings obtained by perturbing marking at postition changeind
	% in mark0 exist in the collection mark_col
	zeroind = find(mark0 == 0);
	n = length(zeroind);
	B = rem(floor([0:2^n-1]'*pow2(-(n-1):0)),2);	% matrix of all elements of {0,1}^(2^n)
	B = 2*B-1; % convert to {-1, 1}
	found = 1;
	for i=1:size(B,1);
		testmark = mark0;
		testmark(zeroind) = B(i,:);
		testmark(changeind) = -mark0(changeind);
		[found,~] = ismember(mark_col,testmark,'rows');
		if ~found
			return
		end
	end
end