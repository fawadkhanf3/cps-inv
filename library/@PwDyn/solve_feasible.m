function [ S ] = solve_feasible(pwd, X, N, no_overlaps)
	%
	% Finds the set S such that from anywhere in S, 
	% X can be reached in N time steps using the
	% dynamics dyn.
	%
	% Inputs:
	% - X 	: Final set (Polyhedron)
	% - dyn : System dynamics (struct)
	% - N 	: Number of time steps (int)
	% - no_overlaps : If true, make parts of S disjoint (bool)
	
	if nargin<4
		no_overlaps = 0;
	end

    S = PolyUnion;
    for i=1:pwd.num_region
        new_poly = intersect1(pwd.reg_list{i}, pwd.dyn_list{i}.solve_feasible(X, N, no_overlaps));
        S = add1(S, new_poly);
    end
end