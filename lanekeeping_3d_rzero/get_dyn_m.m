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
	E = [0; 1; 0];
	Em = [1; 0; K3];
	K = zeros(3,1);

	% Integrate
    A_s = @(s) expm(s*A);
    Ad = A_s(dt);
    Bd = integral(A_s, 0, dt, 'ArrayValued', true, 'AbsTol', 1e-6) * B;
    Kd = zeros(3,1);
    Ed = integral(A_s, 0, dt, 'ArrayValued', true, 'AbsTol', 1e-6) * E;
    Emd = integral(A_s, 0, dt, 'ArrayValued', true, 'AbsTol', 1e-6) * Em;


	XU_set = Polyhedron('A', [0 0 0 1;
							  0 0 0 -1], ...
						'b', [pi/2;
							  pi/2] ...
						);
	XD_plus = [0 0 0 con.alpha_ass*con.g/u0];
	XD_minus = [0 0 0 -con.alpha_ass*con.g/u0];

	Dm_set = Polyhedron('V', [-con.maxv; con.maxv]);

	dyn = Dyn(Ad,Kd,Bd,XU_set,Ed,XD_plus,XD_minus,Emd, Dm_set);
end