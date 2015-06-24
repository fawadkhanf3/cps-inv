function dyn = get_dyn(con, con_lead)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	kappa = con.f1_bar/con.mass;
	ekt = exp(-kappa*con.dT);

	A = [ ekt 			0  0; 
	      (ekt-1)/kappa 1  0;
		  0	 			0  1 ]; 
	B = (1/(con.f1_bar^2))*[ con.f1_bar*(1-ekt) ;
			  				 con.mass*(1-ekt) - con.dT*con.f1_bar;
			  				 0];
	B_cond_number = max(abs(B));
	B = B/B_cond_number;
	
	E = [0 ; con.dT ; 0];
	K = [ (con.f0_bar/con.f1_bar)*(ekt-1) ;
		  (con.f0_bar/(con.f1_bar^2) )*(con.dT*con.f1_bar + con.mass*(ekt-1));
		  0];
	A_xu = [0	0	0  1 ;
			0   0	0  -1;
			ekt*B_cond_number   0  0  (1-ekt)/con.f1_bar;
			-ekt*B_cond_number  0  0  -(1-ekt)/con.f1_bar ];

	adjustment = max(con.f2*(con.v_max-con.lin_speed)^2, con.f2*(con.v_min-con.lin_speed)^2);

	b_xu = [B_cond_number*(con.umax-adjustment); 
	       -B_cond_number*con.umin;
	       B_cond_number*con.v_max-con.f0_bar*B_cond_number*(ekt-1)/con.f1_bar;
	       -B_cond_number*con.v_min+con.f0_bar*B_cond_number*(ekt-1)/con.f1_bar];
	XUset = Polyhedron(A_xu, b_xu);

	XD_plus  = [ 0 0 0 con.vl_max];
	XD_minus = [ 0 0 0 con.vl_min];
	
	dyn = Dyn(A,K,B,XUset,E,XD_plus,XD_minus);
	dyn.save_constant('B_cond_number', B_cond_number);

end