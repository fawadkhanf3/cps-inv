function con = constants

	con.N = 1;

	con.h_des = 2;
	con.h_delta = 0.0;
	con.h_min = 0.1;
	con.v_des = 3.5;
	con.v_delta = 0.1;

	con.dT = 0.1;
	con.lin_speed = 2;

	% Create 3-dimenstional PwDyn object

	con.mass = 9.07;	% kg
	con.f0 = 0.1*con.mass;	% Newton
	con.f1 = 0.05;			% Newton/mps
	con.f2 = 0.0025;		% Newton/mps^2

	con.f0_bar = con.f0 - con.f2*con.lin_speed^2;
	con.f1_bar = con.f1 + 2*con.f2*con.lin_speed;

	con.g = 9.82;
	con.umin = -0.1*con.g*con.mass;	% Newton
	con.umax = 0.06*con.g*con.mass;	% Newton

	% Speed limitaitons for following car [m/s]
	con.v_f_min = -0.02;
	con.v_f_max = 5;

	% Speed limitations for lead car [m/s]
	con.v_l_min = 0;
	con.v_l_max = 5;

	% Constraint on disturbance as a fraction of following car
	% acceleration capabilities
	con.d_max_ratio = 0.9;

	% For simulation
	con.v0 = 3;		% initial speed
	con.d_max = 12; 	% max radar range
end