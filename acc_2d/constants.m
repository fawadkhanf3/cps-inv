% Definition of constants in the 2D problem
function con = constants()
	con.dT = 0.5;

	% Dynamics
    con.g  = 9.82;
	con.mass = 1650;	% kg
    con.f0 = 0.1*con.mass;
    con.f1 = 5;
    con.f2 =  0.25;
	con.umin = -0.3*con.g*con.mass;	% Newton
	con.umax = 0.2*con.g*con.mass;	% Newton

	con.v_linearize = 15; 	% mps

	% State space
	con.v_min = 0;			% mps
	con.v_max = 35;			% mps
	con.h_min = 0;			% m
	con.h_safe = 3;			% m
	con.h_max = 300;		% m

	% Problem parameters
	con.v_lead = 8;		% mps
	con.v_des = 26;			% mps
	con.tau_des = 1.4;		% s
	con.tau_min = 1;		% s

end
