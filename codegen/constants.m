function con = constants

	con.h_des = 0.2;
	con.h_delta = 0.0;
	con.h_min = 0.1;
	con.v_des = 4;
	con.v_delta = 0.1;

	con.dT = 0.1;
	con.lin_speed = 1.5;

	% Create 3-dimenstional PwDyn object

	con.mass = 9.07;	% kg
	con.f0 = 0.1*con.mass;	% Newton
	con.f1 = 5;			% Newton/mps
	con.f2 = 0.25;		% Newton/mps^2

	con.f0_bar = con.f0 - con.f2*con.lin_speed^2;
	con.f1_bar = con.f1 + 2*con.f2*con.lin_speed;

	con.g = 9.82;
	con.umin = -0.3*con.g*con.mass;	% Newton
	con.umax = 0.2*con.g*con.mass;	% Newton

	% Speed limitaitons for following car [m/s]
	con.v_f_min = -0.05;
	con.v_f_max = 10;

	% Distance limitations
	con.d_max = 20;
	con.d_min = 0;

	% Speed limitations for lead car [m/s]
	con.v_l_min = 0;
	con.v_l_max = 5;

	% Constraint on disturbance as a fraction of following car
	% acceleration capabilities
	con.d_max_ratio = 2; % Must be less than 1


end