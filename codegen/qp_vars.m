function [H, f, A_ineq, b_ineq] = qp_vars(x0) %#codegen 
	poly0 = coder.load('poly0_data.mat');
    poly1 = coder.load('poly1_data.mat')
	dyn1 = coder.load('dyn1_data.mat');
	dyn2 = coder.load('dyn2_data.mat');
    dyn3 = coder.load('dyn3_data.mat');
    con = coder.load('constants');

    % Horizon
    N = 2;
    
    if all(dyn2.domainA*x0 <= dyn2.domainb)
        dyn = dyn2;
    elseif all(dyn1.domainA*x0 <= dyn1.domainb)
        dyn = dyn1;
    elseif all(dyn3.domainA*x0 <= dyn3.domainb)
        dyn = dyn3;
    else
        disp(['Warning: outside of region'])
        dyn = dyn2;
    end

    % Space dimensions
    n = size(dyn.A,2);
    m = size(dyn.B,2);
    p = size(dyn.E, 2);

    maxnum = max(size(poly1.A,1), size(poly0.A,1));

    polyA = zeros(maxnum,n);
    polyb = zeros(maxnum,1);

    if all(poly0.A*x0 <= poly0.b)
        polyA(1:size(poly0.A,1), :) = polyA(1:size(poly0.A,1), :) + poly0.A;
        polyb(1:size(poly0.A,1), :) = polyb(1:size(poly0.A,1), :) + poly0.b;
    elseif all(poly1.A*x0 <= poly1.b)
        polyA(1:size(poly0.A,1), :) = polyA(1:size(poly0.A,1), :) + poly0.A;
        polyb(1:size(poly0.A,1), :) = polyb(1:size(poly0.A,1), :) + poly0.b;
    else
        disp(['Warning: outside of sets'])
        polyA(1:size(poly1.A,1), :) = polyA(1:size(poly1.A,1), :) + poly1.A;
        polyb(1:size(poly1.A,1), :) = polyb(1:size(poly1.A,1), :) + poly1.b;
    end


	v = x0(1);
	h = x0(2);
	vl = x0(3);

	% Create MPC weights
	v_goal = min(con.v_des, vl);
	
	lim = 10;
	delta = 20;
	ramp = max(0, min(1, 0.5+abs(v-vl)/delta-lim/delta));

	v_weight = 3.;
	h_weight = 1.*(1-ramp);
	u_weight = 3.;
	u_weight_jerk = 100;
 
	Rx = kron(eye(N), [v_weight 0 0; 0 h_weight 0; 0 0 0]);
	rx = repmat([v_weight*(-v_goal); h_weight*(-1.4); 0],N,1);

	% % weight on velocity
	% Rx(sub2ind([3*N 3*N], 1:3:3*N, 1:3:3*N)) = v_weight*ones(N,1);
	% Rx = Rx + v_weight*diag(repmat([1,0,0],1,N));
	% rx(1:3:3*N) = v_weight*(-v_goal)*ones(N,1);

	% % weight on headway
	% Rx(sub2ind([3*N 3*N], 2:3:3*N, 2:3:3*N)) = h_weight*ones(N,1);
	% Rx = Rx + h_weight*diag(repmat([0,1,0],1,N));
	% rx(2:3:3*N) = h_weight*(-1.4)*vl*ones(N,1);

	Ru = u_weight*eye(N);
	if N>2
		Ru = Ru + u_weight_jerk*(diag([1 2*ones(1,N-2) 1]) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
	else
		Ru = Ru + u_weight_jerk*(diag(ones(1,N)) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
	end
	ru = zeros(N,1);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%% Create dynamics matrices %%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Lx = zeros(n*N, n);
    Lu = zeros(n*N, m*N);
    Ld = zeros(n*N, p*N);
    Lk = zeros(n*N, N);

    AN =  dyn.A;
    ANB = dyn.B;
    ANE = dyn.E;
    ANK = dyn.K;

    for i=1:N
    	diag_mat = kron(eye(N+1-i), ANB);
        % diag_mat = repmat({ANB},1,N+1-i);
        % diag_mat = blkdiag(diag_mat{:});
        Lu(1+n*(i-1):end,1:m*(N+1-i)) = Lu(1+n*(i-1):end,1:m*(N+1-i)) + diag_mat;

        diag_mat = kron(eye(N+1-i), ANK);
        % diag_mat = repmat({ANK},1,N+1-i);
        % diag_mat = blkdiag(diag_mat{:});
        Lk(1+n*(i-1):end,1:(N+1-i)) = Lk(1+n*(i-1):end,1:(N+1-i)) + diag_mat;

        if p>0
    	    diag_mat = kron(eye(N+1-i), ANE);
    	    % diag_mat = repmat({ANE},1,N+1-i);
    	    % diag_mat = blkdiag(diag_mat{:});
    	    Ld(1+n*(i-1):end,1:p*(N+1-i)) = Ld(1+n*(i-1):end,1:p*(N+1-i)) + diag_mat;
    	end
    	
        Lx(1+n*(i-1):n*i,:) = AN;

        ANB = dyn.A*ANB;
        ANK = dyn.A*ANK;
        ANE = dyn.A*ANE;
        AN =  dyn.A*AN;
    end

    Lk = sum(Lk, 2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    LxN1 = Lx(1:n*(N-1),:);
    LuN1 = Lu(1:n*(N-1), 1:m*(N-1));
    LdN1 = Ld(1:n*(N-1), 1:p*(N-1));
    LkN1 = Lk(1:n*(N-1),:);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Create poly constraints %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Add input constraints
    LU = dyn.XUA;
	lU = dyn.XUb;

    LU_x = LU(:,1:n);
    LU_u = LU(:,n+1:n+m);

    dLU_x = kron(eye(N-1), LU_x);
    % dLU_x = repmat({LU_x},1,N-1); 
    % dLU_x = blkdiag(dLU_x{:});
    dLU_u = kron(eye(N-1), LU_u);
    % dLU_u = repmat({LU_u},1,N-1); 
    % dLU_u = blkdiag(dLU_u{:});
    dlU = repmat(lU,N-1,min(1,N-1));

    A_u_X = [ LU_x; 
              dLU_x*LxN1];

    A_u_U = [ LU_u zeros(size(LU_u,1), m*(N-1)); 
              [dLU_x*LuN1 zeros(size(dLU_u,1),m)]+[zeros(size(dLU_u,1),m) dLU_u] ];
    A_u = [A_u_X A_u_U];
    
    b_u = [lU; 
           dlU-dLU_x*LkN1];

    % Add state constraints, x(i) \in poly(i)(perm(i)) for all i
    diagA = kron(eye(N),polyA);
    diagb = repmat(polyb,N,1);
   
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

    A_ineq = HH(:,n+1:n+N*m);
    b_ineq = hh - HH(:,1:n)*x0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Create QP costs %%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    H = Ru + Lu'*Rx*Lu;
    f = ru + Lu'*Rx*(Lx*x0+Lk)+Lu'*rx;

end