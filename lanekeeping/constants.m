function con = constants

	% nominal speed
	con.u0 = 30; %m/s

	% Vehicle parameters
    con.m =1370 ; %kg
    con.Iz= 2315.3; % kgm^2
    con.a=1.11; % m
    con.b = 1.59; % m
    con.L=con.a+con.b;

    con.g = 9.82; %m/s^2

    % Tire parameters
	con.Caf = 1.3308e5; % N/rad 
    con.Car = 9.882e4; % N/rad

    con.F_yfmax = 1000;


end