function [ S ] = solve_feasible(dyn, X, N, no_overlaps)
	%
	% Finds the set S such that from anywhere in S, 
	% X can be reached in N time steps using the
	% dynamics dyn.
	%
	% Inputs:
	% - dyn : System dynamics (struct)
	% - X 	: Final set (Polyhedron)
	% - N 	: Number of time steps (int)
	% - no_overlaps : If true, make parts of S disjoint (bool)

    if ~isa(dyn, 'Dyn')
        error('dyn must be an instance of Dyn');
    end
	
	if nargin<4
		no_overlaps = 0;
	end

	% If target polytope is union
	if isa(X, 'PolyUnion')	
		S = PolyUnion;
		for i=1:X.Num
            new_poly = dyn.solve_feasible(X.Set(i), N);
            S = add1(S, new_poly);
		end
		% if no_overlaps
			% S = remove_overlaps1(S);
		% end
		return
	end

	% If horizon longer than 1
	if N>1
		S0 = dyn.solve_feasible(X,1);
		for i=2:N
			S0 = dyn.solve_feasible(S0,1);
		end
		S = S0;
		return 
	end

	%%%%%%%%%%%%%%%% Standard method %%%%%%%%%%%%%%%%%%%%
	[HH, hh] = dyn.constraint_polytope(X, X, 1);

	P = Polyhedron(HH,hh);
	S = P.projection(1:size(dyn.A, 2));
end


