function [poly1] = post(dyn, poly0) 
    
    %
    % Given a system starting in poly0, find
    % the polytope poly1 which is reachable after 
    % one time step
    %

    n = size(dyn.A, 2);
    m = size(dyn.B, 2);
    p = size(dyn.E, 2);

    nXU = size(dyn.XU_set.A, 1);
    nX0 = size(poly0.A, 1);
    HH = [dyn.XU_set.A;
          poly0.A zeros(nX0,m)];

    hh = [dyn.XU_set.b;
          poly0.b];

    xupoly = Polyhedron(HH,hh);

    if p > 0
        isect_polys = [];
        for i=1:size(dyn.XD_plus,1)
            Dx_plus = dyn.XD_plus(i,1:n);
            Dx_plus_lim = dyn.XD_plus(i,n+1:n+m);
            poly2 = [dyn.A+dyn.E*Dx_plus dyn.B]*xupoly + dyn.E*Dx_plus_lim + dyn.K;
            isect_polys = [isect_polys, {poly2}];
        end
        for i=1:size(dyn.XD_minus,1)
            Dx_minus = dyn.XD_minus(i,1:n);
            Dx_minus_lim = dyn.XD_minus(i,n+1:n+m);
            poly2 = [dyn.A+dyn.E*Dx_minus dyn.B]*xupoly + dyn.E*Dx_minus_lim + dyn.K;
            isect_polys = [isect_polys, {poly2}];
        end
        poly1 = isect_polys{1}
        for i=2:length(isect_polys)
            poly1 = intersection(poly1, isect_polys{i});
        end
    else
        poly1 = [dyn.A dyn.B]*xupoly + dyn.K;
    end
end
