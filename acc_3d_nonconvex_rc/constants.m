% Definition of constants in the 2D problem
function con = constants()

	% car dynamics
	con.mass = 9.07;
	con.f0 = 0.1*con.mass;
	con.f1 = 0.005;
	con.f2 = 0.00025;
	con.g = 9.81;

	% linearization
	con.lin_speed = 2;
	con.f0_bar = con.f0 - con.f2*con.lin_speed^2;
	con.f1_bar = con.f1 + 2*con.f2*con.lin_speed;
	con.dT = 0.1;

	% domain specs
	con.v_min = -0.01;
	con.v_max = 5;
	con.h_min = 0;
	con.h_max = 10;

	% assumptions
	con.umin = -0.07*con.mass*con.g;
	con.umax = 0.05*con.mass*con.g;
	con.vl_min = 0;
	con.vl_max = 4;
	con.al_min = -0.2; % m/s^2
	con.al_max = 0.2;  % m/s^2

	% specifications
	con.h_min = 0.3;   % minimum distance
	con.tau_min = 1; % minimum headway
	con.tau_des = 1.4;
	con.v_des_min = 1.9;
	con.v_des_max = 2.1;

end
