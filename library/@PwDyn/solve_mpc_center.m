function [ min_u ] = solve_mpc_center(pwd, x0, poly0, poly1, N)

    %
    % Maximizes the minimal distance of x(N) to the polytope poly1 edges
    % 

    region_dyn = dyn.get_region_dyn(x0);
    [min_u, feas] = region_dyn.solve_mpc(x0, poly0, poly1, Rx, rx, Ru, ru, N);
end
