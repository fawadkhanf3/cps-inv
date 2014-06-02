function [ min_u, feas ] = solve_mpc( pwadyn,x0, Rx, rx, Ru, ru, polys)
    %
    % Minimizes  (1/2)*x'*Rx*x + rx'*x + (1/2)*u'*Ru*u + ru'*u, 
    % 
    % where u = [ u(0)'' ... u(N-1)']', x = [ x(1)'' ... x(N)']'
    %
    % such that x(1) ... x(N-1) \in poly0 and x(N) \in poly1,
    % subject to the dynamics pwadyn.

    region_dyn = pwadyn.get_region_dyn(x0);
    [min_u, feas] = region_dyn.solve_mpc(x0, Rx, rx, Ru, ru, polys);

end