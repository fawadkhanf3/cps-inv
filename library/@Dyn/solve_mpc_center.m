function [ min_u ] = solve_mpc_center( x0, poly0, poly1, dyn, N)

    %
    % Maximizes the minimal distance of x(N) to the polytope poly1 edges
    % 

    [Lx, Lu, Ld, Lk] = mpc_matrices(dyn, N);

    n = size(dyn.A,2);
    m = size(dyn.B,2);
    
    min_cost = Inf;
    min_u = 0;

    for i=1:length(poly1)
        [HH hh] = constraint_polytope(poly0, poly1, dyn, N);

        hard_A_ineq = HH(:,n+1:n+m);
        hard_b_ineq = hh - HH(:,1:n)*x0;

        center_A_ineq = [poly1.A*Lu(end-n+1:end,:) ones(size(poly1.A,1), 1)];
        center_b_ineq = poly1.b - poly1.A*Lx(end-n+1:end,:)*x0-poly1.A*Lk(end-n+1:end,:);

        A_ineq = [hard_A_ineq zeros(size(hard_A_ineq, 1),1);
                  center_A_ineq];

        b_ineq = [hard_b_ineq; 
                  center_b_ineq];
        
        [u, cost] = linprog([zeros(1,size(A_ineq,2)-1) -1],A_ineq,b_ineq);
        if cost<min_cost
            min_cost = cost;
            min_u = u(1:end-1);
        end
    end
    if min_cost==Inf
        disp('No feasible solution found!')
    end
end
