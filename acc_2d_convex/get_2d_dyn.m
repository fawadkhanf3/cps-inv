function dyn = get_2d_dyn(con)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%% Parameter definitions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	f0_bar = con.f0 - con.f2*con.v_linearize^2;
	f1_bar = con.f1 + 2*con.f2*con.v_linearize;

	umin_bar = con.umin;
	umax_bar = con.umax-con.f2*max((con.v_max-con.v_linearize)^2, (con.v_min-con.v_linearize)^2);

	mass = con.mass;

	v_lead = con.v_lead;

	dT = con.dT;

	dist = 0; % allow for \pm 1 mps uncertainty in lead car velocity

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	kappa = f1_bar/mass;
	ekt = exp(-kappa*dT);

	A = [ ekt 				0 ; 
			  (ekt-1)/kappa 	1 ]; 
	B = (1/(f1_bar^2))*[ f1_bar*(1-ekt) ;
			  				 mass*(1-ekt) - dT*f1_bar ];
	B_cond_number = max(abs(B));
	B_cond_number = B_cond_number;
	B = B/B_cond_number;
	K = [ (f0_bar/f1_bar)*(ekt-1) ;
			  (f0_bar/(f1_bar^2) )*(dT*f1_bar + mass*(ekt-1))  + dT*v_lead];
	% E = [0; 1];
	E = zeros(2,0);

	% Constraints on the form A_xu [x' u']' \leq b_xu, definitng the possible
	% input signals
	A_xu = [ 0	0	1 ;
			0   0	-1 ];
	b_xu = [B_cond_number*umax_bar; -B_cond_number*umin_bar];
	XUset = Polyhedron(A_xu, b_xu);

	XD_plus = [0 0 dT*dist];
	XD_minus = [0 0 -dT*dist];

	% dyn = Dyn(A,B,K,E,XUset,XD_plus, XD_minus);
	dyn = Dyn(A,B,K,E,XUset);
	dyn.save_constant('B_cond_number', B_cond_number);
end