function [Vt] = cinv_oi(dyn, R, rho, maxiter, show_plot, verbose)
	
	% CINV_OI: Compute an invariant set outside-in.
	% ======================================================
	%
	% SYNTAX
	% ------
	%	C = cinv_oi(dyn, R)
	%	C = cinv_oi(dyn, R, rho, maxiter, show_plot, verbose)
	%
	% DESCRIPTION
	% -----------
	%	Computes the maximally controlled-invariant set contained in R
	%
	% INPUT
	% -----
	%	dyn	System dynamics
	% 		Class: Dyn
	%	R 	Goal set
	%		Class: Polyhedron or PolyUnion
	%   maxiter  Maximal number of iterations
	% 		Default: inf
	%	show_plot 	Show plotting while computing
	%		Default: false
	%	verbose 	Output text
	%		Default: false

	if nargin<3 || isempty(rho)
		rho = 0 * ones(dyn.n,1);
	end

	if nargin<4
		maxiter = Inf;
	end

	if nargin<5
		show_plot = 0;
	end

	if nargin<6
		verbose = 0;
	end

	disp('Finding controlled-invariant set by outside-in')
	tic 

	rho_ball = Polyhedron('A', [eye(dyn.n); -eye(dyn.n)], 'b', repmat(rho, 2, 1));

	V = Polyhedron('A', zeros(1,dyn.n), 'b', 1);
	Vt = R;

	iter = 1;
	tic;
	while not (V - rho_ball <= Vt)
		V = Vt;

		Vpre = dyn.pre(V);
		
		if Vpre.isEmptySet
			disp('returned empty')
			Vt = Vpre;
		end

		Vt = Polyhedron('A', [Vpre.A; R.A], 'b', [Vpre.b; R.b]);
		Ct = minHRep(Vt);

	  cc = Ct.chebyCenter;
	  time = toc;
		if verbose
		  disp(['iteration ', num2str(iter), ', ', num2str(size(C.A,1)), ...
        ' ineqs, ball ', num2str(cc.r), ', time ', num2str(time)])		
		end
		iter = iter + 1;
	end
	time = toc;

	disp(['Outside-in controlled-invariant set algo finished in ', num2str(time), ' seconds after ', num2str(iter), ' iterations'])
end