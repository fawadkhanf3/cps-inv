function con = constants

	con.h_des = 1.4;
	con.h_delta = 0.2;
	con.dT = 0.5;
	con.v_des = 28;
	con.v_delta = 3;

	con.v0 = 12;

	con.dT = 0.5;
	con.lin_speed = 15;

	% Create 3-dimenstional PwDyn object

	con.mass = 1650;	% kg
	con.f0 = 0.1*con.mass;	% Newton
	con.f1 = 5;			% Newton/mps
	con.f2 = 0.25;		% Newton/mps^2

	con.f0_bar = con.f0 - con.f2*con.lin_speed^2;
	con.f1_bar = con.f1 + 2*con.f2*con.lin_speed;

	con.g = 9.82;
	con.umin = -0.3*con.g*con.mass;	% Newton
	con.umax = 0.2*con.g*con.mass;	% Newton

	% Speed limitaitons for following car [m/s]
	con.v_f_min = -1;
	con.v_f_max = 35;

	% Distance limitations
	con.d_max = 200;
	con.d_min = 0;

	% Speed limitations for lead car [m/s]
	con.v_l_min = 0;
	con.v_l_max = 35;

	% Constraint on disturbance as a fraction of following car
	% acceleration capabilities
	con.d_max_ratio = 0.8; % Must be less than 1


end