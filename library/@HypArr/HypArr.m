classdef HypArr

	properties (SetAccess=protected)
		Dim;			% Dimension of space
		Num;			% Number of hyperplanes
		hp_matrix; 		% matrix containing the hyperplanes ai'x = bi as [a1 b1; a2 b2 ; ... am bm]
	end

	methods
		% Construct a hyperplane arrangement from a union of Polyhedra
		% If no_envelope == 1, then the envelope halfplanes are not included
		function obj = HypArr(arg1, no_envelope)
			if nargin<2
				no_envelope = 0;
			end

			if isa(arg1, 'Polyhedron')
				arg1 = PolyUnion(arg1);
			end

			if isa(arg1, 'PolyUnion')

				if no_envelope
					env = arg1.envelope();
					H1 = env.H;
					% Normalize entries in H1
					for i=1:size(H1,1)
						H1(i,:) = sign(H1(i,find(H1(i,:),1,'first')))*H1(i,:)/norm(H1(i,:));
					end
				else
					H1 = zeros(0,arg1.Set(1).Dim+1);
				end

				% Collect all hyperplanes
				hp_matrix = zeros(0,arg1.Set(1).Dim+1);
				for poly_num = 1:arg1.Num
					current_poly = arg1.Set(poly_num);
					for hp_num = 1:size(current_poly.A, 1)
						hp = current_poly.H(hp_num, :);
						if norm(hp) == 0
							continue;
						end
						hp_norm_lead1 = sign(hp(find(hp,1,'first')))*hp/norm(hp);
						if ~is_redundant2(hp_matrix, hp_norm_lead1) && ...
						   		  ~is_redundant2(H1, hp_norm_lead1)
							hp_matrix = [hp_matrix; hp_norm_lead1];
						end
					end
				end
				obj.hp_matrix = hp_matrix;
			else
				if size(arg1,2) <= 1
					error('Invalid arg1ument provided to HypArr constructor')
				end
				obj.hp_matrix = arg1;
			end
			obj.Dim = size(obj.hp_matrix,2)-1;
			obj.Num = size(obj.hp_matrix,1);
		end

		function poly = get_poly(hyparr, marking)
			if ~all(size(marking) == [1 hyparr.Num])
				error('Wrong size of marking')
			end
			if all(marking == 0)
				% marking is only zeros, return R^d
				poly = Polyhedron(zeros(1,hyparr.Dim), 0);
				return
			end
			ind_plus = find(marking == 1);
			ind_minus = find(marking == -1);
			HH = [hyparr.hp_matrix(ind_plus,:); -hyparr.hp_matrix(ind_minus,:) ]; 
			poly = Polyhedron('H', HH);
		end	

		function marking = get_marking_point(hyparr, point)
			marking = -sign(hyparr.hp_matrix*[point; -1])';
		end

		function markings = get_marking_poly(hyparr, poly)
			% Returns a vector `markings' with elements in {-1, 0, 1} such that
			% 
			% - markings(i) = 1 if  poly is a subset of the halfspace described by ha_mat(i,:)[x -1] <= 0
			% - markings(i) = -1 if poly is a subset of the halfspace described by ha_mat(i,:)[x -1] >= 0
			% - markings(i) = 0 if poly intersects the hyperplane described by ha_mat(i,:)[x; -1] = 1
			markings = zeros(1,size(hyparr.hp_matrix,1));
			for i = 1:size(hyparr.hp_matrix,1)
				poly1 = Polyhedron('H', hyparr.hp_matrix(i,:));
				poly2 = Polyhedron('H', -hyparr.hp_matrix(i,:));
				if poly1.contains(poly)
					markings(1,i) = 1;
				elseif poly2.contains(poly)
					markings(1,i) = -1;
				end
			end
		end

		function plot_marking(hyparr, markings)
			% Plot polytopes corresponding to markings
			N_mark = size(markings,1);

			col = jet(N_mark);	% colors
			held = ishold;
			hold on
			for i = 1:N_mark
				poly = hyparr.get_poly(markings(i,:));
				plot(poly, 'color', col(i,:));
			end
			if ~held
				hold off
			end
		end
	end
end

function red = is_redundant2(mat, vec)
	red = any(ismember(mat, vec, 'rows'));
end

function red = is_redundant(mat, vec, tol)
	% Returns true if vec is a row of the matrix mat.

	[n, m] = size(mat);

	if (m ~= size(vec,2) || size(vec,1) ~= 1)
		error('Wrong dimensions')
	end

	if norm(vec) == 0
		red = 1;
		return;
	end

	if n == 0
		red = 0;
		return;
	end

	testmat = mat-ones(n,1)*vec;
	test_norm = sqrt(sum(testmat.*testmat, 2));
	if min(test_norm) < tol
		red = 1;
	else
		red = 0;
	end
end