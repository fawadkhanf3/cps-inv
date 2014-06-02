function [C_rbcinv, C_vec] = robust_cinv_3d(maxiter)

	h_des = 1.4;
	h_delta = 0.2;
	dT = 0.5;

	v_des = 30;
	v_delta = 3;

	%%%%%%%%%%%%%%%%%%%%%%%%%	

	disp('Looking for a robustly control-invariant set')

	pwd = get_pw_dyn(dT,70/3.6);

	X = pwd.domain;
	% safe = Polyhedron([1 -1 0; 0 1 0], [0; 200]);
	safe = Polyhedron([1 -1 0], [0]);
	X_safe = intersect(X, safe);

	R = intersect(X, Polyhedron([ -(h_des+h_delta) 1 0 ; h_des-h_delta -1 0], [0; 0]));

	C0 = Polyhedron( [1 0 -1; -1 0 1], [0; 0]);

	% Create different dynamics, using a feedback
	% that keeps the speed constant, and the disturbance is remapped
	% to input to prepare for reachability analysis
	mod_A = pwd.dyn_list{2}.A+pwd.dyn_list{2}.B*[(1-pwd.dyn_list{2}.A(1,1))/pwd.dyn_list{2}.B(1,1) 0 0];
	mod_B = pwd.dyn_list{2}.E;
	mod_K = pwd.dyn_list{2}.K - pwd.dyn_list{2}.B*(pwd.dyn_list{2}.K(1,1)/pwd.dyn_list{2}.B(1,1));
	mod_E = zeros(3,0);
	% Assure that lead car does not exceed top speed
	mod_XUset1 = pwd.dyn_list{1}.xd_poly();
	mod_XUset2 = pwd.dyn_list{2}.xd_poly();
	mod_XUset3 = pwd.dyn_list{3}.xd_poly();

	dyn_mod1 = Dyn(mod_A, mod_B, mod_K, mod_E, mod_XUset1);
	dyn_mod2 = Dyn(mod_A, mod_B, mod_K, mod_E, mod_XUset2);
	dyn_mod3 = Dyn(mod_A, mod_B, mod_K, mod_E, mod_XUset3);

	pwd_mod = PwDyn(pwd.domain, pwd.reg_list, {dyn_mod1, dyn_mod2, dyn_mod3});

	C1 = pwd_mod.post(C0);
	C1i = intersect1(C1, safe);

	C2 = intersect(X_safe, Polyhedron([1 0 0; -1 0 0], [v_des+v_delta; -v_des+v_delta]));
	% C2 = mldivide1(C2, C1i);

	% C1i = PolyUnion([C1i, C2]);
	% plot(C1i)
	% return

	C_iter = C1i;
	C_vec = [C_iter];
	C_rbcinv = PolyUnion;

	for i=2:maxiter
		C = pwd.solve_feasible(C_iter, 1);
		[merged, best] = merge1(C,1,0);
		[~, maxindex] = max(best);
		C_cvx = merged.Set(maxindex);
		C_cvx_safe = intersect1(C_cvx, safe);

		rest = mldivide1(C_iter, C_cvx_safe);
		
		if ~rest.isFullDim
			C_rbcinv = C_iter;
			disp('Found a robustly control-invariant set')
			return
		end

		C_iter = C_cvx_safe;
		C_vec = [ C_vec, C_iter];
	end
	disp('Did not find a robustly control-invariant set. Returning vector of sets.')
end

function merged_poly = merge(pu)
	ha = HypArr(pu);
	white = ha.white_markings(pu);
	merged_poly = ha.merge_nr(white);
end