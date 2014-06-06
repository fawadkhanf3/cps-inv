% Definition of constants in the 2D problem
function con = constants()
	con = {};

	% Dynamics
	con.dT = 0.5;
	con.mass = 1370;	% kg
% 	con.f0 = 0.1*con.mass;	% Newton
% 	con.f1 = 5;			% Newton/mps
% 	con.f2 = 0.25;		% Newton/mps^2
    con.g  = 9.82;

	con.umin = -0.3*con.g*con.mass;	% Newton
	con.umax = 0.2*con.g*con.mass;	% Newton

	con.v_linearize = 15; 	% mps

	con.v0 = 5;				% mps
	con.d0 = 250;			% mps

	% State space
	con.v_max = 35;			% mps
	con.v_min = 0;			% mps
	con.d_max = 300;		% m
	con.d_min = 0;			% m

	% Problem parameters
	con.v_lead = 12;		% mps

	con.v_des = 31;			% mps
	con.v_delta = 3;		% mps
	con.h_des = 1.4;		% s
	con.h_delta = 0.1;		% s
	
    con.R_tire = 0.325;     % m
    Rr_c = 0.0038;
    Rr_v = 0.000026;
    A = 2.3;
    D = 1.206;
    Cd = 0.3;
    con.f0 = Rr_c *con.mass * con.g;
    con.f1 = Rr_v * con.mass * con.g;
    con.f2 =  0.5 * D * A * Cd ;
    

end