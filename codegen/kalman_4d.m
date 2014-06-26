function [x_next, P_next] = kalman_4d(x,P,y,u,dt)

	%
	% Model: x(k+1) = Ax(k) + Bu(k) + K + w
	%        y(k) = C*x(k) + v
	%  where w ~ N(0,Q), v ~ N(0,R)
	% 

	% load some constants
	con = coder.load('constants');
	f0_bar = con.f0_bar;
	f1_bar = con.f1_bar;
	mass = con.mass;

	% Calculate discrete dynamics (depends on dt!)
	kappa = f1_bar/mass;
	ekt = exp(-kappa*dt);

	A = [ ekt 				0 		0      0; 
	      (ekt-1)/kappa 	1 		dt     dt^2/2;
			  0 			0 		1      dt;
			  0 		    0       0      1]; 
	B = (1/(f1_bar^2))*[ f1_bar*(1-ekt) ;
			  				 mass*(1-ekt) - dt*f1_bar ;
			  				 0;
			  				 0 ];

	K = [ (f0_bar/f1_bar)*(ekt-1) ;
		  (f0_bar/(f1_bar^2) )*(dt*f1_bar + mass*(ekt-1)) ;
		  0;
		  0 ];

    C = [1 0 0 0; 0 1 0 0];

    % Q = diag([0 dt^3/3 dt^2/2 dt]);
    qvec = [0 sqrt(dt^3/3) sqrt(dt^2/2) sqrt(dt)];
    Q = qvec'*qvec;
    R = 0.1*dt*eye(2);

    % Do Kalman updates
    x_next_pred = A*x + B*u + K;
    P_next_pred = A*P*A' + Q;

    inn = y - C*x_next_pred;
    inn_convar = C*P_next_pred*C' + R;

    gain = P_next_pred*C'*inv(inn_convar);

    x_next = x_next_pred + gain*inn;
    P_next = (eye(4)-gain*C)*P_next_pred;

    % Ugly hacks to keep speeds positive
    x_next(1) = max(x_next(1), 1e-5)
    x_next(3) = max(x_next(3), 1e-5);
end