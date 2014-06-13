function dyn = get_dyn(con)

	% State is [ y psi r ]'
	%
	% y 	- lateral position wrt lane center line
	% psi 	- yaw angle
	% r 	- yaw rate
	%
	% Continuous time dynamics
	% \dot y    = u0 psi
	% \dot psi  = r + d
	% \dot r    = rdot 
	%
	% Discrete time dynamics
	% y(t+dt)   = y(t) + u0 dt * psi(t) + u dt^2/2 * r(t) + u dt^3/6 * ( rdot(t) + u(t) )
	% psi(t+dt) = psi(t) + dt * r(t)                      + dt^2/2   * ( rdot(t) + u(t) )
	% r(t+dt)   = r(t)                                    + dt 		 * ( rdot(t) + u(t) )

	% The control here is `r_dot':
	% \dot r = r_dot

	% Input constraint:
	%
	% |r_dot + b^2 C_ar/(u Iz) * r|  <=  F_yfmax * a / Iz
	%

	A = [1  con.u0*con.dt  con.u0*con.dt^2/2;
		 0  1              con.dt;
		 0  0              1];
	B = [con.u0*con.dt^3/6; con.dt^2/2; con.dt];
	E = [con.u0*con.dt^2/2; con.dt; 0];
	K = zeros(3,1);

	XU_set = Polyhedron('A', [0 0 con.b^2*con.Car/(con.u0*con.Iz) 1;
							  0 0 -con.b^2*con.Car/(con.u0*con.Iz) -1], ...
						'b', [con.F_yfmax*con.a/con.Iz;
							  con.F_yfmax*con.a/con.Iz] ...
						);
	XD_plus = [0 0 0 con.alpha_ass*con.g/con.u0];
	XD_minus = [0 0 0 -con.alpha_ass*con.g/con.u0];

	dyn = Dyn(A,B,K,E,XU_set,XD_plus,XD_minus);
end