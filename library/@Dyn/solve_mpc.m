function [ min_u, min_cost, feas ] = solve_mpc(dyn, x0, Rx, rx, Ru, ru, polys, opts)
    % SOLVE_MPC: Solve an optimal control problem with quadratic costs and
    % linear constraints.
    % ======================================================
    %
    % SYNTAX
    % ------
    %   [u, cost] = solve_mpc(dyn, x0, Rx, rx, Ru, ru, polys)
    %
    % DESCRIPTION
    % -----------
    %   Minimizes  (1/2)*x'*Rx*x + rx'*x + (1/2)*u'*Ru*u + ru'*u, 
    % 
    %   where u = [ u(0)'' ... u(N-1)']', x = [ x(1)' ... x(N)']'
    %
    %   such that x(i) \in polys(i) for i=1 ... N,
    %   subject to the dynamics dyn.
    %
    % INPUT
    % -----
    %   dyn     System dynamics
    %           Class: Dyn
    %   x0      Initial state in R^d
    %   Rx, rx  State weight matrix and vector
    %   Ru, ru  Control weight matrix and vector
    %   polys   Polyhedra representing linear constraints
    %           Class: Array of Polyhedron or PolyUnion
    %   opts    Optimization options for quadprog, see `help optimoptions'
    %
    % OUTPUT
    % -----
    %   min_u    Optimal control signal
    %   min_cost Cost of optimal control signal

    if nargin<8
        opts = optimoptions('quadprog','Algorithm','interior-point-convex','display','None');
    end

    if ~isa(dyn, 'Dyn')
        error('dyn must be an instance of Dyn');
    end

    N = length(polys);
    Nn = ones(1,N);
    for i=1:N
        if isa(polys(i), 'PolyUnion')
            Nn(i) = polys(i).Num;
        end
    end
    
    [Lx, Lu, Ld, Lk] = mpc_matrices(dyn, N);

    n = size(dyn.A,2);
    m = size(dyn.B,2);

    U_cost_MAT = Ru + Lu'*Rx*Lu;
    U_cost_VEC = ru + Lu'*Rx*(Lx*x0+Lk)+Lu'*rx;
    
    min_cost = Inf;
    min_u = 0;
    feas = 0;

    vecs = {};
    for i=1:N
        vecs{i} = 1:Nn(i);
    end

    permutations = allcomb(vecs{:});
    for i=1:prod(Nn) % test each combination of multi-steps
        current = permutations(i,:);

        [HH hh] = dyn.constraint_polytope(polys, current);

        A_ineq = HH(:,n+1:n+N*m);
        b_ineq = hh - HH(:,1:n)*x0;

        [u, cost, flag] = quadprog(U_cost_MAT,U_cost_VEC,A_ineq,b_ineq, ...
                             [],[],[],[],[],opts);
        
        if flag==1 && cost<min_cost
            min_cost = cost;
            min_u = u;
            feas = 1;
        end
    end
    if min_cost==Inf
        disp('No feasible solution found!')
        feas = 0;
    end
end
