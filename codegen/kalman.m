function [x_next, P_next] = kalman(x,P,y,u,dt)

	con = coder.load('constants');

	f0_bar = con.f0_bar;
	f1_bar = con.f1_bar;
	mass = con.mass;

	%
	% Model: x(k+1) = Ax(k) + Bu(k) + K + w
	%        y(k) = C*x(k) + v
	%  where w ~ N(0,Q), v ~ N(0,R)
	% 

	% Calculate discrete dynamics (depends on dt!)

	kappa = f1_bar/mass;
	ekt = exp(-kappa*dt);

	A = [ ekt 				0 		0 ; 
	      (ekt-1)/kappa 	1 		dt;
			  0 				0 		1]; 
	B = (1/(f1_bar^2))*[ f1_bar*(1-ekt) ;
			  				 mass*(1-ekt) - dt*f1_bar ;
			  				 0 ];

	K = [ (f0_bar/f1_bar)*(ekt-1) ;
		  (f0_bar/(f1_bar^2) )*(dt*f1_bar + mass*(ekt-1)) ;
		  0 ];

	C = [1 0 0; 0 1 0];

	Q = diag([0 0 3*dt]);
	R = 0.5*dt*eye(2);

	B_mod = [K B];
	u_mod = [1; u];

	% Do Kalman updates
	x_next_pred = A*x + B_mod*u_mod;
	P_next_pred = A*P*A' + Q;

	inn = y - C*x_next_pred;
	inn_convar = C*P_next_pred*C' + R;

	gain = P_next_pred*C'*inv(inn_convar);

	x_next = x_next_pred - gain*y;
	P_next = (eye(3)-gain*C)*P_next_pred;

end