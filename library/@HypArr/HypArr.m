classdef HypArr
    % HypArr: Create a HypArr object.
    % ========================================
    %
    % SYNTAX
    % ------
    %
    %   ha = HypArr(PU);
    %   ha = HypArr(PU, no_env);
    % 
    % DESCRIPTION
    % 
    %   Creates a Hyperplane arrangement from a union of Polyhedra
    %
    % INPUT
    % -----
    %
    % PU : Polyhedron union
    %      class: PolyUnion
    %
    % no_env: If true, disregard envelope halfplanes
    %      class: boolean
    %
    % METHODS
    % -------
    % 
    % Construct Polyhedron from marking 
    %  get_poly(ha, marking) 
    % 
    % Construct marking from Polyhedron
    %  get_marking_poly(ha, poly)
    %
    % Construct marking from point p
    %  get_marking_poly(ha, p)
    %
    % Plot marking(s)
    %  plot_marking(ha, markings)

	properties (SetAccess=protected)
		Dim;			% Dimension of space
		Num;			% Number of hyperplanes
		hp_matrix; 		% matrix containing the hyperplanes ai'x = bi as [a1 b1; a2 b2 ; ... am bm]
		envelope;       % envelope of polys that created envelope
		has_envelope;
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
					obj.envelope = arg1.envelope().H;
					obj.has_envelope = false;
					env_normH = obj.envelope;
					% Normalize entries in env_normH
					for i=1:size(env_normH,1)
						env_normH(i,:) = sign(env_normH(i,find(env_normH(i,:),1,'first')))*env_normH(i,:)/norm(env_normH(i,:));
					end
				else
					obj.envelope = zeros(0,arg1.Set(1).Dim+1);
					has_envelope = true;
					env_normH = obj.envelope;
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
						if ~is_redundant(hp_matrix, hp_norm_lead1) && ...
						   		  ~is_redundant(env_normH, hp_norm_lead1)
							hp_matrix = [hp_matrix; hp_norm_lead1];
						end
					end
				end
				obj.hp_matrix = hp_matrix;
			else
				if size(arg1,2) <= 1
					error('Invalid argument provided to HypArr constructor')
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
			if hyparr.has_envelope
				HH = [hyparr.hp_matrix(ind_plus,:); -hyparr.hp_matrix(ind_minus,:) ]; 
			else
				HH = [hyparr.hp_matrix(ind_plus,:); -hyparr.hp_matrix(ind_minus,:); hyparr.envelope]; 
			end
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
				plot(poly, 'color', col(i,:), 'alpha', 0.3);
			end
			if ~held
				hold off
			end
		end
	end
end

function red = is_redundant(mat, vec, tol)
	% Returns true if vec is a row of the matrix mat.

	if nargin<3
		tol = 1e-7;
	end

	for i=1:size(mat, 1)
		if (norm(mat(i,:) - vec) < tol)
			red = true;
			return;
		end
	end
	red = false;
end