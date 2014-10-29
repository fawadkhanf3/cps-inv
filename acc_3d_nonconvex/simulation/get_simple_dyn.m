function dyn = get_simple_dyn(con)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	kappa = con.f1_bar/con.mass;
	ekt = exp(-kappa*con.dT);

	A = [ ekt ]; 
	B = (1/(con.f1_bar^2))*[ con.f1_bar*(1-ekt)];
	B_cond_number = max(abs(B));
	B = B/B_cond_number;
	K = [ (con.f0_bar/con.f1_bar)*(ekt-1) ];
	A_xu = [ 0	1 ;
			0   -1;
			ekt*B_cond_number (1-ekt)/con.f1_bar;
			-ekt*B_cond_number  -(1-ekt)/con.f1_bar ];
	b_xu = [B_cond_number*con.umax; 
	       -B_cond_number*con.umin;
	       B_cond_number*con.v_max-con.f0_bar*B_cond_number*(ekt-1)/con.f1_bar;
	       -B_cond_number*con.v_min+con.f0_bar*B_cond_number*(ekt-1)/con.f1_bar];
	XUset = Polyhedron(A_xu, b_xu);
	
	dyn = Dyn(A,K,B,XUset);
	dyn.save_constant('B_cond_number', B_cond_number);
end