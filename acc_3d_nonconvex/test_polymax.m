clf; hold on

poly_vmax = Polyhedron('H', [0 1 0 con.tau_des*(con.v_des_max + con.v_des_min)/2]);
poly200 = Polyhedron([ 0 1 0], [200]);

Cinv_low = Cinv_vec;
for i=1:length(Cinv_vec)
	Cinv_low(i) = intersect(Cinv_vec(i), poly_vmax);
	plot(intersect1(Cinv_vec(i), poly200), 'color', 'blue', 'alpha', 0.05)
end

test_mat = {Cinv_low};

% for t=1:6
% 	Ct_vec = [];

% 	for i=1:length(test_mat{end})
%         C1 = intersect1(pwadyn.reg_list{1}, pwadyn.dyn_list{1}.pre(test_mat{end}(i)));
%         C2 = intersect1(pwadyn.reg_list{2}, pwadyn.dyn_list{2}.pre(test_mat{end}(i)));
%         C3 = intersect1(pwadyn.reg_list{3}, pwadyn.dyn_list{3}.pre(test_mat{end}(i)));

%         Ci_cvx = C2;
%         if ~C1.isEmptySet && isNeighbor(C2, C1)
% 			Ci_cvx = merge_in(Ci_cvx, C1);
% 		end
%         if ~C3.isEmptySet && isNeighbor(C2, C3)
% 			Ci_cvx = merge_in(Ci_cvx, C3);
% 		end

% 		Ci_cvx = intersect1(S1, Ci_cvx);
% 		Ct_vec = [Ct_vec Ci_cvx];
% 	end

% 	plot(intersect1(Ci_cvx, poly200), 'color', 'green', 'alpha', 0.2)

% 	test_mat = [test_mat {Ct_vec}];
% end



plot(Cinv_low, 'color', 'red', 'alpha', 0.2)
plot(intersect(pwadyn.domain, Polyhedron('He', [0 1 0 con.tau_des*(con.v_des_max + con.v_des_min)/2])), 'alpha', 0.2, 'color', 'gray')
xlabel('v')
ylabel('h')
zlabel('v_L')