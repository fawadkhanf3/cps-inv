function [poly1] = post(pwd, poly0) 
    
    %
    % Given a system starting in poly0, find
    % the polytope poly1 which is reachable after 
    % one time step
    %

    polyfuns = makepolyfuns;
    isect = intersect(poly0, pwd.reg_list{1});
    polylist = post(pwd.dyn_list{1}, isect);
    for i=2:pwd.num_region
        isect = intersect(poly0, pwd.reg_list{i});
        newpoly = post(pwd.dyn_list{i}, isect);
        polylist = [polylist newpoly];
    end
    poly1 = polyfuns.convexify(polylist);
end