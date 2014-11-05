% Definition of constants in the 2D problem
function con = constants()
	con.dT = 0.1;

	% Dynamics
    con.g  = 9.82;
	con.mass = 10;	% kg
    con.f0 = 0.1*con.mass;
    con.f1 = 5;
    con.f2 =  0.25;
	con.umin = -0.3*con.g*con.mass;	% Newton
	con.umax = 0.2*con.g*con.mass;	% Newton

	con.v_linearize = 2; 	% mps

	% State space
	con.v_min = 0;			% mps
	con.v_max = 4;			% mps
	con.h_min = 0;			% m

	% Problem parameters
	con.v_lead = 0.21;		% mps
	con.v_des = 2.5;	% mps
	con.d_min = 0.3;	% m
	con.tau_des = 1;	% s
	con.tau_min = 0.5;

end
