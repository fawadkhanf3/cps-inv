function [Lx, Lu, Ld, Lk] = mpc_matrices(dyn,N)
    
    %  Given a dynamical system and a horizon N,
    %  returns the matrices such that 
    %
    %   [ x(t+1)                        [ u(0) ;             [ d(0) ;   
    %       .          =   Lx x(0) + Lu    .            + Ld    .       + Lk
    %       .                              .                    .       
    %     x(t+N) ]                        u(N-1) ]            d(N-1)   

    if ~isa(dyn, 'Dyn')
        error('dyn is not an instance of Dyn')
    end

    A = dyn.A;
    B = dyn.B;
    E = dyn.E;
    K = dyn.K;

    n = dyn.n;
    m = dyn.m;
    p = dyn.p;

    Lx = zeros(n*N, n);
    Lu = zeros(n*N, m*N);
    Ld = zeros(n*N, p*N);
    Lk = zeros(n*N, N);

    AN = A;
    ANB = B;
    ANE = E;
    ANK = K;

    for i=1:N
        diag_mat = kron(eye(N+1-i), ANB);
        Lu(1+n*(i-1):end,1:m*(N+1-i)) = Lu(1+n*(i-1):end,1:m*(N+1-i)) + diag_mat;

        diag_mat = kron(eye(N+1-i), ANK);
        Lk(1+n*(i-1):end,1:(N+1-i)) = Lk(1+n*(i-1):end,1:(N+1-i)) + diag_mat;

        if p>0
            diag_mat = kron(eye(N+1-i), ANE);
    	    Ld(1+n*(i-1):end,1:p*(N+1-i)) = Ld(1+n*(i-1):end,1:p*(N+1-i)) + diag_mat;
    	end
    	
        Lx(1+n*(i-1):n*i,:) = AN;

        ANB = A*ANB;
        ANK = A*ANK;
        ANE = A*ANE;
        AN = A*AN;
    end

    Lk = sum(Lk, 2);
end
