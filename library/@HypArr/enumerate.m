function markings = enumerate(ha, envmarking)
	if nargin == 2
		envpoly = ha.get_poly(envmarking);
		x0 = bounded_cheby(envpoly);
		c0 = ha.get_marking_point(x0);
		while any(c0 == 0)
			rn = randn(ha.Dim,1);
			if envpoly.contains(x0+rn);
				c0 = ha.get_marking_point(x0+rn);
			end
		end
	else
		envmarking = 0;
		c0 = zeros(1,ha.Num);
		while any(c0==0)
			x0 = randn(ha.Dim,1);
			c0 = -sign(ha.hp_matrix(:,1:ha.Dim)*x0 - ha.hp_matrix(:,ha.Dim+1))'; % starting cell
		end
	end

	poly0 = ha.get_poly(c0); % starting polytope
	p0 = bounded_cheby(poly0);
	markings = c0;
	if nargin < 2
		changeind = 1:length(c0); % change all indices
	else
		changeind = find(envmarking == 0); % only change indices inside env
	end
	markings = iterate(ha, c0, p0, markings, changeind);
end

function markings = iterate(ha, c0, p0, markings, changeind)
	for ii = 1:length(changeind)
		i = changeind(ii);
		[is_adj, adjmarking, adjpoly] = adjacent(ha, c0, i);
		if is_adj	% check if we get adjacent poly by flipping i
			p_adj = bounded_cheby(adjpoly);  % get characteristic point of adjacent poly
			if f(ha, p_adj, adjpoly, p0, 1e-7) == i  % check if adjacent poly maps to current poly - we found inverse of f
				markings = [markings; adjmarking]; % add new marking

				% Code for plotting process
				% poly_this = ha.get_poly(c0);
				% p_this = bounded_cheby(poly_this);
				% plot([p_this(1) p_adj(1)], [p_this(2) p_adj(2)], 'k');
				% plot(p_adj(1), p_adj(2), 'k*')

				markings = iterate(ha, adjmarking, p0, markings, changeind); % continue search
			end
		end
	end
end

function fval = f(ha, p, poly, p0, tol)
	% Find the index of the hyperplane in ha which is closest to p along the vector p0-p

	if norm(p-p0) < tol
		fval = -1; % Don't want to return root of tree
		return;
	end
	tA = poly.A*(p0-p);
	tb = poly.b-poly.A*p;
	tpoly = Polyhedron('A', tA, 'b', tb);
 	sol = tpoly.extreme(1);
 	t_max = sol.x;
 	x_max = p + (p0-p)*t_max;
 	fvals = find(abs(ha.hp_matrix*[x_max; -1]) < tol);
 	if length(fvals) > 1
 		% If conflict, choose that smallest index that renders an adjacent polytope
 		c0 = ha.get_marking_point(p);
 		for i = 1:length(fvals)
 			[adj, ~, ~] = adjacent(ha, c0, fvals(i));
 			if adj
 				fval = fvals(i);
 				return
 			end
 		end
 	end
 	fval = fvals(1);
end

function [adj, adj_marking, adj_poly] = adjacent(ha, c, i)
	adj_marking = c;
	adj_marking(i) = -adj_marking(i);
	adj_poly = ha.get_poly(adj_marking);
	if adj_poly.isFullDim
		adj = 1;
	else
		adj = 0;
	end
end

function cc = bounded_cheby(poly)
	sol = chebyCenter(poly, [], 1); % should find some characteristic length of the HypArr
	cc = sol.x;
end
