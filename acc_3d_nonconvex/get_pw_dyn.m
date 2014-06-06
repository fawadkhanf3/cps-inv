function pwd = get_pw_dyn(dT, lin_speed)

	% Create 3-dimenstional PwDyn object

	mass = 1650;	% kg
	f0 = 0.1*mass;	% Newton
	f1 = 5;			% Newton/mps
	f2 = 0.25;		% Newton/mps^2

	f0_bar = f0 - f2*lin_speed^2;
	f1_bar = f1 + 2*f2*lin_speed;

	umin = -0.3*9.82*mass;	% Newton
	umax = 0.2*9.82*mass;	% Newton

	% Speed limitaitons for following car [m/s]
	v_f_min = 10/3.6;
	v_f_max = 120/3.6;

	% Distance limitations
	d_max = 200;
	d_min = 0;

	% Speed limitations for lead car [m/s]
	v_l_min = 10/3.6;
	v_l_max = 120/3.6;

	% Constraint on disturbance as a fraction of following car
	% acceleration capabilities
	d_max_ratio = 0.5; % Must be less than 1

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	kappa = f1_bar/mass;
	ekt = exp(-kappa*dT);

	A = [ ekt 				0 		0 ; 
			  (ekt-1)/kappa 	1 		dT;
			  0 				0 		1]; 
	B = (1/(f1_bar^2))*[ f1_bar*(1-ekt) ;
			  				 mass*(1-ekt) - dT*f1_bar ;
			  				 0 ];
	B_cond_number = max(abs(B));
	B_cond_number = B_cond_number;
	B = B/B_cond_number;
	E = [0 ; dT^2/2; dT];
	E = E;
	K = [ (f0_bar/f1_bar)*(ekt-1) ;
			  (f0_bar/(f1_bar^2) )*(dT*f1_bar + mass*(ekt-1)) ;
			  0 ];
	A_xu = [ 0	0	0	1 ;
			0   0	0	-1;
			ekt*B_cond_number 0   0   (1-ekt)/f1_bar;
			-ekt*B_cond_number 0   0   -(1-ekt)/f1_bar ];
	b_xu = [B_cond_number*umax; 
	       -B_cond_number*umin;
	       B_cond_number*v_f_max-f0_bar*B_cond_number*(ekt-1)/f1_bar;
	       -B_cond_number*v_f_min+f0_bar*B_cond_number*(ekt-1)/f1_bar];
	XUset = Polyhedron(A_xu, b_xu);

	% Figure out cut-off points
	plus_constant = (d_max_ratio/dT)*((1-ekt)*umax+f0_bar*(ekt-1))/f1_bar;
	v_plus_coef = (d_max_ratio/dT)*(ekt-1);
	v_plus_co = (v_l_max-dT*plus_constant)/(dT*v_plus_coef+1);

	min_constant = (d_max_ratio/dT)*((1-ekt)*umin+f0_bar*(ekt-1))/f1_bar;
	v_min_coef = (d_max_ratio/dT)*(ekt-1);
	v_min_co = (v_l_min-dT*min_constant)/(dT*v_min_coef+1);

	% Limitations on disturbance
	XD_plus_mid = [ 0 0 v_plus_coef plus_constant ];
	XD_minus_mid = [ 0 0 v_min_coef min_constant ];
	
	XD_minus_low = [0 0 -1/dT v_l_min/dT];
	XD_plus_high = [0 0 -1/dT v_l_max/dT];

	region = Polyhedron([diag([1 0 1]); -diag([1 0 1])], [v_f_max; d_max; v_l_max; -v_f_min; -d_min; -v_l_min]);
	reg1 = intersect(region, Polyhedron([0 0 1], [v_min_co]));
	reg2 = intersect(region, Polyhedron([0 0 1; 0 0 -1], [v_plus_co; -v_min_co]));
	reg3 = intersect(region, Polyhedron([0 0 -1], [-v_plus_co]));

	dyn1 = Dyn(A,B,K,E,XUset,XD_plus_mid,XD_minus_low);
	dyn2 = Dyn(A,B,K,E,XUset,XD_plus_mid,XD_minus_mid);
	dyn3 = Dyn(A,B,K,E,XUset,XD_plus_high,XD_minus_mid);

	reg_list = {reg1, reg2, reg3};
	dyn_list = {dyn1, dyn2, dyn3};
	
	pwd = PwDyn(region, reg_list, dyn_list);
end