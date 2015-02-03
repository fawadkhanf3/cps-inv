% Definition of constants in the 2D problem
function con = constants()
	con.dT = 0.5;

	% Dynamics
    con.g  = 9.82;
	con.mass = 1370;	% kg
    con.f0 = 3.8*10^(-3)*con.mass*con.g;
    con.f1 = 2.6*10^(-5)*con.mass*con.g;
    con.f2 =  0.4161;
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
	con.v_lead = 12;			% mps
	con.v_des = 34;			% mps
	con.tau_des = 1.3;		% s
	con.tau_min = 1;		% s

end
