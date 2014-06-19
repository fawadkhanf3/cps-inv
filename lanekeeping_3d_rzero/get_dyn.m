function dyn = get_dyn2(con)

	% State is [ y psi r ]'
	%
	% y 	- lateral position wrt lane center line
	% psi 	- yaw angle
	% r 	- yaw rate
	%
	% Continuous time dynamics
	% \dot y    = u0 psi
	% \dot psi  = r + d
	% \dot r    = -(a^2 Caf + b^2 Car)/(Iz*u) r + a Caf /Iz deltaf 
	%
	% The control here is `deltaf':

	u0 = con.u0; dt = con.dt;
	K1 = -(con.a^2*con.Caf + con.b^2*con.Car)/(con.Iz*u0);
	K2 = con.a*con.Caf/con.Iz;
	K3 = (con.b*con.Car-con.a*con.Caf)/(con.Iz*con.u0);
	% Continuous system
	A = [0  u0  0;
		 0  0   1;
		 0  0   K1];
	B = [0; 0; K2];
	E = [0 1; 1 0; 0 K3];
	K = zeros(3,1);

	% Exact discrete system
	% eKd = exp(K1*dt);
	% Ad1 = [1 	u0*dt 	(u0/K1^2)*( eKd - K1*dt - 1 );
	% 	   0 	1	    (1/K1)*( eKd - 1 );
	% 	   0	0		eKd ]
	% Bd1 = [ -(K2*u0/(2*K1^3))*( 2 - 2*eKd + K1*dt*(2+K1*dt) );
	% 		(K2/K1^2)*( eKd - K1*dt - 1);
	% 		(K2/K1)*(eKd-1) ]
	% Ed1 = [u0*dt^2/2;
	% 	   dt;
	% 	   0]

	% Integrate
    A_s = @(s) expm(s*A);
    Ad = A_s(dt);
    Bd = integral(A_s, 0, dt, 'ArrayValued', true, 'AbsTol', 1e-6) * B;
    Kd = zeros(3,1);
    Ed = integral(A_s, 0, dt, 'ArrayValued', true, 'AbsTol', 1e-6) * E;


	XU_set = Polyhedron('A', [0 0 0 1;
							  0 0 0 -1], ...
						'b', [pi/2;
							  pi/2] ...
						);
	XD_plus = [0 0 0 con.alpha_ass*con.g/u0;
			   0 0 0 1];
	XD_minus = [0 0 0 -con.alpha_ass*con.g/u0;
				0 0 0 -1];

	dyn = Dyn(Ad,Bd,Kd,Ed,XU_set,XD_plus,XD_minus);
end