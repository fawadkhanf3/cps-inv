function [HH, hh] = constraint_polytope(dyn, poly0, poly1, N)
	%
	% Return HH and hh such that 
	%  
	%     [ x(0); 
	% HH    u(0);     \leq hh
	%       ...
	%	    u(N-1)]
	%
	% enforces x(1),...,x(N-1) to stay in poly0, and x(N) to be in poly1, wrt dyn

    %
    % Comment: Does not support horizon length larger than 1. Two things
    % should be fixed: 
    % 1. Fix the input constraints.
    % 2. Fix the disturbance bounds.

    if nargin<4
        N=1;
    end

	if isa(poly1, 'PolyUnion')
		error('contraint_polytope() can not be called with a PolyUnion')
	end

	n = size(dyn.A, 2);
	m = size(dyn.B, 2);
	p = size(dyn.E, 2);

	% Input constraints NEEDS FIX FOR N>1
	HH = [ dyn.XU_set.A];
	hh = [ dyn.XU_set.b];

	% Block matrix of polytope constraints
    if N>1
        diag = repmat({poly0.A},1,N-1);
        Hstack = blkdiag(diag{:});
        Hstack = blkdiag(Hstack, poly1.A);
        c = repmat(poly0.b, N-1,1);
        d = poly1.b;
        hstack = [c; d];
    else
        Hstack = poly1.A;
        hstack = poly1.b;
    end
   
    % Dynamics
	[ Lx, Lu, Ld, Lk ] = mpc_matrices(dyn, N);

    % NEEDS FIX FOR N>1 and p>1
	if p>0
		% Add all corners in disturbance polytope
        for i=1:size(dyn.XD_plus,1)
            Dx_plus = dyn.XD_plus(i,1:n);
            Dx_plus_lim = dyn.XD_plus(i,n+1:n+m);
            HH = [HH; 
                  Hstack*Lx+Hstack*Ld*Dx_plus       Hstack*Lu];
            hh = [hh;
                  hstack-Hstack*Lk-Hstack*Ld*Dx_plus_lim];
        end
        for i=1:size(dyn.XD_minus,1)
	        Dx_minus = dyn.XD_minus(i,1:n);
	        Dx_minus_lim = dyn.XD_minus(i,n+1:n+m);
            [Hstack*Lx+Hstack*Ld*Dx_minus        Hstack*Lu];
            HH = [HH; 
			      Hstack*Lx+Hstack*Ld*Dx_minus		Hstack*Lu];
            hh = [hh;
			      hstack-Hstack*Lk-Hstack*Ld*Dx_minus_lim];
        end
	else
		HH = [HH; 
			  Hstack*Lx 	Hstack*Lu];
		hh = [hh ;
			  hstack-Hstack*Lk];	
	end	
end