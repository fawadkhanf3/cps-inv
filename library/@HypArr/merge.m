function [markings nrs] = merge(ha, whitemark, objective)
	blackmark = ha.black_markings(whitemark);

	switch objective
		case 1
			[markings, nrs] = merge_recursive_maxnr(ha, whitemark, blackmark, 0);
		case 2
			vols = zeros(1,size(whitemark,1));
			for i=1:length(vols)
				vols(i) = volume(ha.get_poly(whitemark(i,:)));
			end
			[markings, nrs] = merge_recursive_maxvol(ha, whitemark, blackmark, vols, 0);
		case 3
			markings = merge_recursive_minnr(ha, whitemark, blackmark, 0, size(whitemark,1));
			nrs = size(markings,1);
	end
end

function [new_markings, new_nrs] = merge_recursive_maxnr(ha, white, black_0, best_nr)
	% Perform a branch-and-bound search to find a representation such that
	% the volume of the largest polytope in the representation is maximized.

	env_mark = env(white);
	if sum(abs(env_mark)) ~= 0
		black = inside(black_0, env_mark);
	else
		black = black_0;
	end

	% No white markings
	if size(white,1) == 0
		new_markings = zeros(0,size(white,2));
		new_nrs = zeros(0,1);
		return;
	end

	% No black markings -> envelope is the union
	if size(black,1) == 0
		new_markings = env_mark;
		new_nrs = size(white,1);
		return
	end

	zero_ind = find(env_mark == 0); % Dividing hyperplanes
	sums = abs(sum(white(:,zero_ind),1)); % Count how divisive index i is
	[~, sortindex] = sort(sums, 2, 'descend');
	zero_ind = zero_ind(sortindex); % Most divisive first

	best_markings = white;
	best_nrs = ones(1,size(white,1));
	for i = zero_ind
		[white_plus, white_min] = divide(white, i);
		[black_plus, black_min] = divide(black, i);
		if max([size(white_plus,1), size(white_min,1)]) > best_nr
			[new_whites_plus, new_nrs_plus] = ...
				merge_recursive_maxnr(ha, white_plus, black_plus, best_nr);

			[new_whites_min, new_nrs_min] = ...
				merge_recursive_maxnr(ha, white_min, black_min, max([new_nrs_plus best_nr]) );

			new_best_nr = max([new_nrs_plus new_nrs_min]);
			if new_best_nr > best_nr
				best_nr = new_best_nr;
				best_markings = [new_whites_min; new_whites_plus];
				best_nrs = [new_nrs_min new_nrs_plus];
			end
		end
	end
	new_markings = best_markings;
	new_nrs = best_nrs;
end

function [new_markings, new_volumes] = merge_recursive_maxvol(ha, white, black_0, vols, best_vol)
	% Perform a branch-and-bound search to find a representation such that
	% the volume of the largest polytope in the representation is maximized.

	env_mark = env(white);
	if sum(abs(env_mark)) ~= 0
		black = inside(black_0, env_mark);
	else
		black = black_0;
	end

	% No white markings
	if size(white,1) == 0
		new_markings = zeros(0,size(white,2));
		new_volumes = zeros(1,0);
		return;
	end

	% No black markings -> envelope is the union
	if size(black,1) == 0
		new_markings = env_mark;
		new_volumes = sum(vols);
		return
	end

	zero_ind = find(env_mark == 0); % Dividing hyperplanes
	best_markings = white;
	best_volumes = vols;
	for i = zero_ind
		[white_plus, white_min, plus_ind, min_ind] = divide(white, i);
		[black_plus, black_min] = divide(black, i);
		vols_plus = vols(plus_ind);
		vols_min = vols(min_ind);
		if max([sum(vols_plus), sum(vols_min)]) > best_vol

			[new_whites_plus, new_vols_plus] = ...
				merge_recursive_maxvol(ha, white_plus, black_plus, vols_plus, best_vol);
			if length(new_whites_plus) == 0
				new_vols_plus = zeros(1,0);
			end
			[new_whites_min, new_vols_min] = ...
				merge_recursive_maxvol(ha, white_min, black_min, vols_min, best_vol);
			if length(new_whites_min) == 0
				new_vols_min = zeros(1,0);
			end
			new_best_vol = max([new_vols_plus new_vols_min]);
			if new_best_vol > best_vol
				best_vol = new_best_vol;
				best_markings = [new_whites_min; new_whites_plus];
				best_volumes = [new_vols_min new_vols_plus];
			end
		end
	end 
	new_markings = best_markings;
	new_volumes = best_volumes;
end

function [new_markings] = merge_recursive_minnr(ha, white, black_0, z, zbar)
	% Perform a branch-and-bound search to find a representation such that
	% the volume of the largest polytope in the representation is maximized.

	env_mark = env(white);
	if sum(abs(env_mark)) ~= 0
		black = inside(black_0, env_mark);
	else
		black = black_0;
	end

	% No white markings
	if size(white,1) == 0
		new_markings = zeros(0,size(white,2));
		return;
	end

	% No black markings -> envelope is the union
	if size(black,1) == 0
		new_markings = env_mark;
		return
	end

	zero_ind = find(env_mark == 0); % Dividing hyperplanes
	sums = abs(sum(white(:,zero_ind),1)); % Count how divisive index i is
	[~, sortindex] = sort(sums, 2, 'descend');
	zero_ind = zero_ind(sortindex); % Most divisive first

	best_markings = white;
	for i = zero_ind
		if z < zbar
			[white_plus, white_min] = divide(white, i);
			[black_plus, black_min] = divide(black, i);

			new_whites_plus = merge_recursive_minnr(ha, white_plus, black_plus, z, zbar);
			num_plus = size(new_whites_plus,1);
			new_whites_min = merge_recursive_minnr(ha, white_min, black_min, z, zbar);
			num_min = size(new_whites_min,1);

			if num_plus+num_min < size(best_markings,1)
				best_markings = [new_whites_plus; new_whites_min];
				zbar = min([zbar z+size(best_markings,1)]);
			end
		end
	end 
	new_markings = best_markings;
end

function [plus_mark, min_mark, plus_ind, min_ind] = divide(markings, i)
	plus_ind = find(markings(:,i) == 1 );
	min_ind = find(markings(:,i) == -1 );
	plus_mark = markings(plus_ind, :);
	min_mark = markings(min_ind, :);
end

function env_mark = env(markings)
	% Get the marking of the envelope of `markings'
	[N_m, N_hp] = size(markings);
	env_mark = fix(sum(markings, 1)/N_m);
end

function new_marks = inside(marks, mark0)
	% Get the subset of marks that are inside mark0

	ind_nonzero = find(mark0 ~= 0);
	marks_restriction = marks(:, ind_nonzero);
	ind_keep = find(sum(abs( marks_restriction - ...
			 repmat(mark0(1,ind_nonzero), size(marks_restriction,1), 1)),2) == 0);
	new_marks = marks(ind_keep, :);
end