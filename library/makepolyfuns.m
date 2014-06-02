function funs = makepolyfuns()
	funs.intersect = @intersect_wrapper;
	funs.volume = @volume_wrapper;
	funs.convexify = @convexify;
	funs.remove_empty = @remove_empty;
	funs.remove_overlaps = @remove_overlaps;
	funs.reduce = @reduce_wrapper;
	funs.simplify = @simplify_polytope;
	funs.is_inside = @is_inside;
	funs.find_set = @find_set;
	funs.order = @order;
	funs.add = @add_wrapper;
end

% Intersection of polyhedra arrays



% Computes total volume of polyhedra array
% Does not take care of overlaps


function [pfin] = convexify(polyarray, k)
	%
	% Works on a polytope array and does two things
	% 1. If polyarray contains overlapping polytopes, these are split
	%    into the intersections
	% 2. Looks for convex unions within the array, starting at sets of 
	% 	 size k and going down to sets of size 2.

	if nargin<2
		k=3;
	end

	if length(polyarray) == 1
		pfin = polyarray;
		return;
	end

	% Remove overlappings
	if PolyUnion(polyarray).isOverlapping()
		parray = remove_overlaps(polyarray);
	else
		parray = polyarray;
	end

	% Merge
	new_list = [];
	N = length(parray);
	N0 = N;
	k = min(N,k);
	while k>1
		combs = uniqueperms([ones(1,k), zeros(1,N-k)]);
		found = 0;
		for i=1:size(combs,1)
			ind = find(combs(i,:));
			test = PolyUnion(parray(ind));
			if test.isConvex()
				found = 1;
				merge(test);
				new_list = [new_list test.Set];
				parray = parray(setdiff(1:N,ind)); % remove added polys
				N = length(parray);
				k = min(N,k);
				break;
			end
		end
		if ~ found
			k = k-1;
		end
	end

	% Add remaining polytopes
	new_list = [new_list parray];
	% disp(['Removed ', num2str(N0-N), ' superfluous polys'])
	pfin = new_list;
end


% Removes redundant (wrt overlapping) polytopes in 
% an array
function [poly] = reduce_wrapper(polyunion)
	disp('Reducing')
	if ~ strcmp(class(polyunion),'PolyUnion')
		disp('Error in reduce_wrapper')
	end

	ind = find(reduce(polyunion));
	poly = PolyUnion(polyunion.Set(ind));
end

% Tries to shrink the polytope by removing some 
% vertices
function [simple_poly] = simplify_polytope(poly, dist) 

	if length(poly)>1
		simple_poly = [];
		for i=1:length(poly)
			simple_poly = [simple_poly simplify_polytope(poly(i), dist)];
		end
		return;
	end

	poly.minVRep();
	vert = poly.V;
	s0 = size(vert, 1);

	new_vert_ind = [];

	for i=1:size(vert, 1)
		add_vertex = true;
		for j=i+1:size(vert, 1)
			if norm(vert(i,:) - vert(j,:))<dist
				add_vertex = false;
				break;
			end
		end
		if add_vertex
			new_vert_ind = [new_vert_ind i];
		end
	end
	s1 = size(new_vert_ind,2);
	disp(strcat({'Kept '}, num2str(s1), {' of '}, num2str(s0), {' vertices'}));
	simple_poly = Polyhedron(vert(new_vert_ind, :));
	simple_poly.computeHRep();
	if ~simple_poly.isFullDim()
		% If dist was too large
		disp('Not fulldim!');
		simple_poly = poly;
	end
end

% Computes unique permutations of a vector
% in an efficient manner
function pu = uniqueperms(vec)
	vec = vec(:); % make it always a column vector
	n = length(vec);

	uvec = unique(vec);
	nu = length(uvec);

	% any special cases?
	if isempty(vec)
		pu = [];
	elseif nu == 1
		% there was only one unique element, possibly replicated.
		pu = vec';
	elseif n == nu
		% all the elements are unique. Just call perms
		pu = perms(vec);
	else
		% 2 or more elements, at least one rep
		pu = cell(nu,1);
		for i = 1:nu
			v = vec;
			ind = find(v==uvec(i),1,'first');
			v(ind) = [];
			temp = uniqueperms(v);
			pu{i} = [repmat(uvec(i),size(temp,1),1),temp];
		end
		pu = cell2mat(pu);
	end
end

function [ret] = is_inside(polyvec, point)

	if length(polyvec)>1
		ret = 0;
		for i=1:length(polyvec)
			if polyvec(i).contains(point)
				ret = 1;
				return;
			end
		end
		return;
	end
	ret = polyvec.contains(point)
end

function [num] = find_set(sets, point)

  for i=1:length(sets)
    if is_inside(sets{i},point)
      num = i;
      return;
    end
  end
  disp('Not inside any set..');
  num = -1;
end