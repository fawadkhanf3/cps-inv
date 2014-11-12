function [H, f, A_ineq, b_ineq] = qp_vars(x0) %#codegen 

    dyn =           coder.load('dyn_data.mat');
    con =           coder.load('constants.mat');
    polys =         coder.load('poly.mat');
    
    N = con.con.N;

    % are we safe?
    all_safe = 0;

    % Space dimensions
    n = size(dyn.A,2);
    m = size(dyn.B,2);
    p = size(dyn.E,2);

    % Find maximum # of ineqs
    maxnum = max(polys.bigPolyLen);

    polyA = zeros(maxnum,n);
    polyb = zeros(maxnum,1);

    A = polys.bigPolyA(polys.bigPolyStartInd(1): polys.bigPolyStartInd(1) + polys.bigPolyLen(1) - 1, :);
    b = polys.bigPolyb(polys.bigPolyStartInd(1): polys.bigPolyStartInd(1) + polys.bigPolyLen(1) - 1, :);

    if all(A*x0 <= b)
        polyA(1:size(A,1), :) = polyA(1:size(A,1), :) + A;
        polyb(1:size(b,1), :) = polyb(1:size(b,1), :) + b;
        all_safe = 1;
    else
        for i=2:length(polys.bigPolyLen)
            A = polys.bigPolyA(polys.bigPolyStartInd(i):polys.bigPolyStartInd(i)+polys.bigPolyLen(i) - 1, :);
            b = polys.bigPolyb(polys.bigPolyStartInd(i):polys.bigPolyStartInd(i)+polys.bigPolyLen(i) - 1, :);
            if all(A*x0 <= b)
                A_1 = polys.bigPolyA(polys.bigPolyStartInd(i-1):polys.bigPolyStartInd(i-1) + polys.bigPolyLen(i-1) - 1, :);
                b_1 = polys.bigPolyb(polys.bigPolyStartInd(i-1):polys.bigPolyStartInd(i-1) + polys.bigPolyLen(i-1) - 1, :);
                polyA(1:size(A_1,1), :) = polyA(1:size(A_1,1), :) + A_1;
                polyb(1:size(b_1,1), :) = polyb(1:size(b_1,1), :) + b_1;
                all_safe = 1;
                break;
            end
        end
    end

	v = x0(1);
	h = x0(2);
 %    vl = con.con.v_lead;

	% % Create MPC weights
	% v_goal = min(con.con.v_des, vl);
	
	% lim = 1;
	% delta = 2;
	% ramp = max(0, min(1, 0.5+abs(v-vl)/delta-lim/delta));

	% v_weight = control_con.control_con.v_weight;
	% h_weight = control_con.control_con.h_weight.*(1-ramp);
 %    u_weight = control_con.control_con.u_weight;
 %    u_weight_jerk = control_con.control_con.u_weight_jerk;
 
	% Rx = kron(eye(N), [v_weight 0; 0 h_weight]);
	% rx = repmat([v_weight*(-v_goal); h_weight*(-con.con.tau_des*v)],N,1);

	% Ru = u_weight*eye(N);
	% if N>2
	% 	Ru = Ru + u_weight_jerk*(diag([1 2*ones(1,N-2) 1]) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
	% else
	% 	Ru = Ru + u_weight_jerk*(diag(ones(1,N)) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
	% end
	% ru = zeros(N,1);

    [Rx,rx,Ru,ru] = mpc_weights(v,h,N,con.con);

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
        Lu(1+n*(i-1):end,1:m*(N+1-i)) = Lu(1+n*(i-1):end,1:m*(N+1-i)) + diag_mat;

        diag_mat = kron(eye(N+1-i), ANK);
        Lk(1+n*(i-1):end,1:(N+1-i)) = Lk(1+n*(i-1):end,1:(N+1-i)) + diag_mat;

        if p>0
    	    diag_mat = kron(eye(N+1-i), ANE);
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
    % LdN1 = Ld(1:n*(N-1), 1:p*(N-1));
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
    dLU_u = kron(eye(N-1), LU_u);
    dlU = repmat(lU,max(1,N-1),1);

    A_u_X = [ LU_x; 
              dLU_x*LxN1];

    A_u_U = [ LU_u zeros(size(LU_u,1), m*(N-1)); 
              [dLU_x*LuN1 zeros(size(dLU_u,1),m)]+[zeros(size(dLU_u,1),m) dLU_u] ];
    A_u = [A_u_X A_u_U];
    
    b_u = [lU; 
           dlU-dLU_x*LkN1];

    % Add state con.constraints, x(i) \in poly(i)(perm(i)) for all i
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

    if ~all_safe
        A_ineq(size(A_u,1)+1:end, :) = zeros(size(A_ineq,1)-size(A_u,1), size(A_ineq,2));
        b_ineq(size(A_u,1)+1:end) = ones(size(A_ineq,1)-size(A_u,1),1);
    end

end