function [HH, hh] = constraint_polytope_2(dyn, polys, perm)
    % CONSTRAINT_POLYTOPE: Compute polytopes that represent joint 
    % constraints on initial state and inputs that keep the states in
    % a given set of polytopes.
    % ======================================================
    %
    % SYNTAX
    % ------
    %   [HH, hh] = constraint_polytope(dyn, polys, perm)
    %   [HH, hh] = constraint_polytope(dyn, polys)
    %
    % DESCRIPTION
    % -----------
    % Computes a (n+N*m)x(n+N*m) matrix HH and a (n+N*m)x1 vector hh such that
    % 
    %     [ x(0); 
    % HH    u(0);     <=  hh
    %       ...
    %       u(N-1)]
    %
    % enforces x(i) \in polys(i)(perm(i)) for i=1 ... N, where polys is a vector of Polyhedron/PolyUnion
    %
    % Remark: disturbance is not accounted for in later steps, as this might make the problem
    % infeasible. Rather, in problems with disturbance the disturbance is only accounted for in
    % one step.
    % 
    % INPUT
    % -----
    %   dyn     System dynamics
    %           Class: Dyn
    %   polys   Polyhedra representing linear constraints
    %           Class: Array of Polyhedron or PolyUnion
    %   perm    A given permutation in the case of PolyUnion
    %           Default: ones(1,N)

    if nargin<3
        perm = ones(1,length(polys));
    end

    N = length(perm);

    if ~(N==length(polys))
        error('wrong size')
    end

    n = size(dyn.A, 2);
	m = size(dyn.B, 2);
	p = size(dyn.E, 2);

    % Take care of input constraints; form A_u, b_u such that A_u [ x(0); u(0) .. u(N-1)] < b_u
    % enforces LU [x(i); u(i)] < lU for all i.
	LU = dyn.XU_set.A;
	lU = dyn.XU_set.b;

    LU_x = LU(:,1:n);
    LU_u = LU(:,n+1:n+m);

    [ LxN1, LuN1, LdN1, LkN1 ] = mpc_matrices(dyn, N-1);

    dLU_x = repmat({LU_x},1,N-1); 
    dLU_x = blkdiag(dLU_x{:});
    dLU_u = repmat({LU_u},1,N-1); 
    dLU_u = blkdiag(dLU_u{:});
    dlU = repmat(lU,N-1,1);

    A_u_X = [ LU_x; 
              dLU_x*LxN1];

    A_u_U = [ LU_u zeros(size(LU_u,1), m*(N-1)); 
              [dLU_x*LuN1 zeros(size(dLU_u,1),m)]+[zeros(size(dLU_u,1),m) dLU_u] ];
    A_u = [A_u_X A_u_U];

    b_u = [lU; 
           dlU-dLU_x*LkN1];

    % Add state constraints, x(i) \in poly(i)(perm(i)) for all i
    diagA = [];
    diagb = [];
    for i=1:N
        poly_i = polys(i);
        if isa(poly_i, 'PolyUnion')
            if perm(i)>poly_i.Num
                error('perm too large')
            end
            poly_i = poly_i.Set(perm(i));
        else
            if perm(i)~=1
                error('wrong in perm')
            end
        end
        diagA = blkdiag(diagA, poly_i.A);
        diagb = [diagb; poly_i.b];
    end
   
	[ Lx, Lu, Ld, Lk ] = mpc_matrices(dyn, N);

    if p>0
        XD_plus_x = dyn.XD_plus(:,1:n);
        XD_plus_d = dyn.XD_plus(:,n+1);

        XD_minus_x = dyn.XD_minus(:,1:n);
        XD_minus_d = dyn.XD_minus(:,n+1);

        Ld_0 = Ld(:,1:p); % part of Ld acting on d(0) - only disturbance we care about

        HH = [A_u; 
              diagA*Lx+diagA*Ld_0*XD_plus_x  diagA*Lu;
              diagA*Lx+diagA*Ld_0*XD_minus_x diagA*Lu];
        hh = [b_u ;
              diagb-diagA*Lk-diagA*Ld_0*XD_plus_d;
              diagb-diagA*Lk-diagA*Ld_0*XD_minus_d];  
    else
    	HH = [A_u; 
    		  diagA*Lx 	diagA*Lu];
    	hh = [b_u ;
    		  diagb-diagA*Lk];	
    end
end