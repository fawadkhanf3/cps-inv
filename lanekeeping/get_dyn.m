function dyn = get_dyn(con)

	% The control here is `r_dot':

	% \dot r = r_dot

	% Input constraint:
	%
	% |r_dot + b^2 C_ar/(u Iz) * r|  <=  F_yfmax * a / Iz
	%

	A = [0 con.u0 0;
		 0 0      1;
		 0 0      0];
	B = [0; 0; 1];
	E = zeros(3,0);
	K = zeros(3,1);

	XU_set = Polyhedron('A', [0 0 con.b^2*con.Car/(con.u0*con.Iz) 1;
							  0 0 -con.b^2*con.Car/(con.u0*con.Iz) -1], ...
						'b', [con.F_yfmax*con.a/con.Iz;
							  con.F_yfmax*con.a/con.Iz] ...
						);

	dyn = Dyn(A,B,K,E,XU_set);
end