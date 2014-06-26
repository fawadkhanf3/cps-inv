function dyn = get_dyn(con)

	% State is [ y r psi r ]'
	%
	% y 	- lateral position wrt lane center line
	% r 	- lateral velocity
	% psi 	- yaw angle
	% r 	- yaw rate
	%

	Car = con.Car; Caf = con.Caf; a = con.a; b = con.b; u0 = con.u0;
	m = con.m; Iz = con.Iz; dt = con.dt;

	% Continuous dynamics
    A=[0 1 u0 0; 
      0 -(Caf+Car)/(m*u0) 0 ((b*Car-a*Caf)/(m*u0) - u0); 
      0 0 0 1;
      0 (b*Car-a*Caf)/(Iz*u0)  0 -(a^2 * Caf + b^2 * Car)/(Iz*u0)];

    B=[0;Caf/m; 0; a*Caf/Iz];

    E=[0;0;-1;0];

    Cy=[1 0 0 0]; % use w/ y
    c=[1 0 20 0]; % use w/ y_preview

    Sys=ss(A,B,c,0);
    Kd=.25; Kp=4;
    Q=Kp*c'*c + Kd*A'*c'*c*A;
    R=600;
    [K,Slqr,Elqr]=lqr(Sys,Q,R);

	%%%%% Reduction 1
	SysCL=ss(A-B*K,B,Cy,0)

	SysCLReduced = balred(SysCL,3)

	[SysCLbalanced, g, T, Ti] = balreal(SysCL)

	%%%%% Reduction 2 using y_preview in place of y
	SysCL2=ss(A-B*K,B,c,0)

	SysCLReduced2 = balred(SysCL2,3)

	[SysCLbalanced2, g2, T2, Ti2] = balreal(SysCL2)

	A = SysCLReduced.A;
	B = SysCLReduced.B;
	E = 

    % Integrate dynamics
    A_s = @(s) expm(s*A);
    Ad = A_s(dt);
    Bd = integral(A_s, 0, dt, 'ArrayValued', true) * B;
	Kd = zeros(3,1);
    Ed = integral(A_s, 0, dt, 'ArrayValued', true) * E;

    XU_set = Polyhedron([0 0 0 0 1; 0 0 0 0 -1], [pi/3; pi/3]);

  	XD_plus = [0 0 0 0 con.alpha_ass*con.g/con.u0];
  	XD_minus = [0 0 0 0 -con.alpha_ass*con.g/con.u0];

    dyn = Dyn(Ad,Bd,Kd,Ed,XU_set,XD_minus, XD_plus);
end