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


	A = [1  con.u0  0;
		 0  0       1;
		 0  0       -(con.a^2*con.Caf + con.b^2*con.Car)/(con.Iz*con.u0)];
	B = [0; 0; con.a*con.Caf/con.Iz];
	E = [0; 1; 0];
	K = zeros(3,1);

	% Integrate it 
    A_s = @(s) expm(s*A);
    Ad = A_s(con.dt);
    Bd = integral(A_s, 0, con.dt, 'ArrayValued', true) * B;
    Kd = zeros(3,1);
    Ed = integral(A_s, 0, con.dt, 'ArrayValued', true) * E;

	XU_set = Polyhedron('A', [0 0 0 1;
							  0 0 0 -1], ...
						'b', [pi/2;
							  pi/2] ...
						);
	XD_plus = [0 0 0 con.alpha_ass*con.g/con.u0];
	XD_minus = [0 0 0 -con.alpha_ass*con.g/con.u0];

	dyn = Dyn(Ad,Kd,Bd,XU_set,Ed,XD_plus,XD_minus);
end