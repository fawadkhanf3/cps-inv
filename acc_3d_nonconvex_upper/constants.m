%% constants: 
function [con] = constants()

	% car dynamics
	con.mass = 1370;
	con.f0 = 0.1;
	con.f1 = 5;
	con.f2 = 0.25;
	con.g = 9.82;

	% linearization
	con.lin_speed = 10;
	con.f0_bar = con.f0 - con.f2*con.lin_speed^2;
	con.f1_bar = con.f1 + 2*con.f2*con.lin_speed;
	con.dT = 0.5;

	% domain specs
	con.v_min = -0.1;
	con.v_max = 35;
	con.h_min = 0;
	con.h_max = 200;

	% assumptions
	con.umin = -0.3*con.mass*con.g;
	con.umax = 0.2*con.mass*con.g;
	con.vl_min = 0;
	con.vl_max = 20;
	con.al_min = -2; % m/s^2
	con.al_max = 1;  % m/s^2

	% specifications
	con.h_min = 3;   % minimum distance
	con.tau_min = 1; % minimum headway
	con.tau_des_min = 1.2;
	con.tau_des_max = 1.6;
	con.v_des_min = 24;
	con.v_des_max = 26;

	% simulation
	con.v0 = 12;
end