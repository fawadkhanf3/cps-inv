function con = control_constants()
	con.N = 5;
	con.v_weight = 1;
	con.h_weight = 5;
	con.u_weight = 100;
	con.u_weight_jerk = 10;

	con.ramp_lim = 0.3;		% 
	con.ramp_delta = 0.6;
end
