function pwd = get_pw_dyn(con)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	kappa = con.f1_bar/con.mass;
	ekt = exp(-kappa*con.dT);

	A = [ ekt 				0 		0 ; 
			  (ekt-1)/kappa 	1 		con.dT;
			  0 				0 		1]; 
	B = (1/(con.f1_bar^2))*[ con.f1_bar*(1-ekt) ;
			  				 con.mass*(1-ekt) - con.dT*con.f1_bar ;
			  				 0 ];
	B_cond_number = 1; %max(abs(B));
	B = B/B_cond_number;
	
	% E = [0 ; 0; 0];
	E = [0 ; con.dT^2/2; con.dT];
	K = [ (con.f0_bar/con.f1_bar)*(ekt-1) ;
			  (con.f0_bar/(con.f1_bar^2) )*(con.dT*con.f1_bar + con.mass*(ekt-1)) ;
			  0 ];
	A_xu = [ 0	0	0	1 ;
			0   0	0	-1;
			ekt*B_cond_number 0   0   (1-ekt)/con.f1_bar;
			-ekt*B_cond_number 0   0   -(1-ekt)/con.f1_bar ];
	b_xu = [B_cond_number*con.umax; 
	       -B_cond_number*con.umin;
	       B_cond_number*con.v_f_max-con.f0_bar*B_cond_number*(ekt-1)/con.f1_bar;
	       -B_cond_number*con.v_f_min+con.f0_bar*B_cond_number*(ekt-1)/con.f1_bar];
	XUset = Polyhedron(A_xu, b_xu);

	acceleration_max = con.d_max_ratio*con.umax/con.mass;
	acceleration_min = con.d_max_ratio*con.umin/con.mass;

	% Figure out cut-off points
	cutoff_upper = con.v_l_max - acceleration_max*con.dT;
	cutoff_lower = con.v_l_min - acceleration_min*con.dT;

	% Limitations on disturbance
	XD_plus_mid = [ 0 0 0 acceleration_max];
	XD_minus_mid = [ 0 0 0 acceleration_min];
	
	XD_plus_high = [0 0 -1/con.dT con.v_l_max/con.dT];
	XD_minus_low = [0 0 -1/con.dT con.v_l_min/con.dT];

	region = Polyhedron([1 0 0; 0 0 1; -1 0 0; 0 0 -1], [con.v_f_max; con.v_l_max; -con.v_f_min; -con.v_l_min]);
	reg1 = intersect(region, Polyhedron([0 0 1], [cutoff_lower]));
	reg2 = intersect(region, Polyhedron([0 0 1; 0 0 -1], [cutoff_upper; -cutoff_lower]));
	reg3 = intersect(region, Polyhedron([0 0 -1], [-cutoff_upper]));

	dyn1 = Dyn(A,K,B,XUset,E,XD_plus_mid,XD_minus_low);
	dyn1.save_constant('B_cond_number', B_cond_number);
	dyn2 = Dyn(A,K,B,XUset,E,XD_plus_mid,XD_minus_mid);
	dyn2.save_constant('B_cond_number', B_cond_number);
	dyn3 = Dyn(A,K,B,XUset,E,XD_plus_high,XD_minus_mid);
	dyn3.save_constant('B_cond_number', B_cond_number);

	reg_list = {reg1, reg2, reg3};
	dyn_list = {dyn1, dyn2, dyn3};
	
	pwd = PwDyn(region, reg_list, dyn_list);
end