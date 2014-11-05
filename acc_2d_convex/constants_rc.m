% Definition of constants in the 2D problem
function con = constants()
	con.dT = 0.1;

	% Dynamics
    con.g  = 9.82;
	con.mass = 9.07;	% kg
    con.f0 = 0.1*con.mass;
    con.f1 = 0.05;
    con.f2 =  0.0025;
	con.umin = -0.07*con.g*con.mass;	% Newton
	con.umax = 0.05*con.g*con.mass;	% Newton

	con.v_linearize = 2; 	% mps

	% State space
	con.v_min = 0;			% mps
	con.v_max = 4;			% mps
	con.h_min = 0;			% m
	con.h_max = 10;			% m  use CC controller above

	% Problem parameters
	con.v_lead = 1;		% mps
	con.v_des = 2.5;	% mps
	con.h_safe = 0.3;	% m
	con.tau_des = 1;	% s
	con.tau_min = 1;

end
