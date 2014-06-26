function [ X0 ] = solve_feasible(dyn, X, N)
    % SOLVE_FEASIBLE: Find a backward-time reachable set.
    % ======================================================
    %
    % SYNTAX
    % ------
    %   X0 = solve_feasible(dyn, X, N)
    %
    % DESCRIPTION
    % -----------
	% 	Finds the set S such that from anywhere in S, 
	% 	X can be reached in N time steps using the
	% 	dynamics dyn.
    %
    % 	If dyn contains disturbance, this is taken into
    %	account by assuming the worst case disturbance.
    % 
    % INPUT
    % -----
    %   dyn     System dynamics
    %           Class: Dyn
    %   X   	Final set
    %           Class: Polyhedron or PolyUnion
    %   N 	    Number of time steps
    %           Default: 1

	if nargin<3
		N = 1;
	end

    if ~isa(dyn, 'Dyn')
        error('dyn must be an instance of Dyn');
    end
	
	% If target set is PolyUnion
	if isa(X, 'PolyUnion')	
		X0 = PolyUnion;
		for i=1:X.Num
            new_poly = dyn.solve_feasible(X.Set(i), N);
            X0 = add1(X0, new_poly);
		end
		return
	end

	% If horizon longer than 1
	if N>1
		X0_iter = dyn.solve_feasible(X,1);
		for i=2:N
			X0_iter = dyn.solve_feasible(X0_iter,1);
		end
		X0 = X0_iter;
		return 
	end

	% Project a polytope
	[HH, hh] = dyn.constraint_polytope2(X);
	P = Polyhedron(HH,hh);
	X0 = P.projection(1:dyn.n);
end


