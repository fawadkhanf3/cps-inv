function con = constants

	% time step
	con.dt = 0.02;

	% nominal speed
	con.u0 = 30; %m/s

	% Vehicle parameters
    con.m =1370 ; %kg
    con.Iz= 2315.3; % kgm^2
    con.a=1.11; % m
    con.b = 1.59; % m
    con.L=con.a+con.b;

    con.g = 9.82; %m/s^2

    % Maximal assumed road curvature as alpha*g
    con.alpha_ass = 0.2;

    % Road curvature in simulation
    con.alpha_road = 0.15;

    % Tire parameters
	con.Caf = 1.3308e5; % N/rad 
    con.Car = 9.882e4; % N/rad

    % con.F_yfmax = 1500;
    con.F_yfmax = 6660; % from Omar

end