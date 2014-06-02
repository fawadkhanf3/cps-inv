function [K2_1 K2_2] = get_control_sets_2d(dyn, con, show_plot)

	if nargin<3
		show_plot = 0;
	end

	disp('Loading set controller...')

	v_max = con.v_max;
	v_min = con.v_min;
	d_max = con.d_max;
	d_min = con.d_min;

	h_des = con.h_des;
	h_delta = con.h_delta;

	v_des = con.v_des;
	v_delta = con.v_delta;

	%%%%%%%%%%%%%%%%%%%%%%%%

	%% State space
	X = Polyhedron([eye(2); -eye(2)], [v_max; d_max; -v_min; -d_min]);

	%% Safe area
	safe = Polyhedron([1 -1; 0 -1], [0; -1]);
	X_safe = intersect1(X, safe);

	%%% Desired areas

	%% Good headway
	M1 = 

	%% Good headway
	M2 = intersect1(X, Polyhedron('V', ...
		[ 0 				1;
		  0					5; 
		v_des-v_delta 		(h_des-h_delta)*(v_des-v_delta);
		v_des-v_delta 		(h_des+h_delta)*(v_des-v_delta) ]));

	%% Good speed
	M2p = intersect1(X_safe, Polyhedron('A', ...
			[ 1 			0; 
			 -1 			0; 
			 h_des-h_delta 	-1], ...
			'b', ...
			[v_des+v_delta; 
			-v_des + v_delta; 
			0 ]));

	%% Slowdown area
	dist = 5*v_des; % At what distance we should start thinking about slowing down
	M2pp = Polyhedron('V', ...
		[ 0 			5; 
		v_des-v_delta 	(h_des+h_delta)*(v_des-v_delta);
		v_des-v_delta	dist ]);

	M = PolyUnion([R2 R2p R2pp]); % Target region
	M = merge1(R);

	%% Use outside-in approach
	C1 = dyn.cinv_oi(R2, show_plot, 1e-3);

	%% Use inside-out approach starting with V0
	C0 = intersect1(R2, Polyhedron([1 0; -1 0], [con.v_lead; -con.v_lead])); 
	C1 = dyn.cinv_io(R2, C0, 0);

	if show_plot
		pause(1);
	end
	
	K1_1

	% Find control strategy
	K2_1 = dyn.backwards_chain(C1, R, show_plot, 1e-3);
	K2_2 = dyn.backwards_chain(vector_poly1(end), X_safe, show_plot, 1e-3);
  	disp('Finished loading the controller.')
end

function [mu] = mu(u, con)
	mu = (con.f0-u)/con.f2  - (con.f1/(2*con.f2))^2;
end

function [gamma] = gamma(u, con)
	gamma = sqrt(abs(mu(u, con)));
end

function [speed] = speed(v0,t,u,con)
	gma = gamma(u,con);
	beta = -(con.f2/con.mass)*gma*t;
	speed = -con.f1/(2*con.f2) + gma*( v0 + con.f1/(2*con.f2) +gma*tan(beta) )./ ...
									   ( gma - (v0 + con.f1/(2*con.f2))*tan(beta)  );
end

function [time] = slowdown_time(v0, v1, u, con)
    mu0 = mu(u, con);
    if (mu0<0)
        disp('Error in slowdown_time!');
    end 
    gma = gamma(u, con);
    time = (con.mass/(gma*con.f2))*( atan( (v0 + (con.f1/(2*con.f2)) )/gma ) - ...
                              atan( (v1 + (con.f1/(2*con.f2)) )/gma ) );
end

function [dist] = distance(v0, t, u, con)
    gma = gamma(u, con);
    dist = -con.f1*t/(2*con.f2) + (con.mass/con.f2)*log( abs(  ...
        cos(-con.f2*gma*t/con.mass) - ...
        ((v0 + con.f1/(2*con.f2))/gma)*sin(-con.f2*gma*t/con.mass)  ...
    ) );
end

function [dist] = slowdown_distance(v0, v1, u, con)
    time = slowdown_time(v0,v1, u, con);
    dist = distance(v0, time, u, con);
end

function [dist] = min_headway(v0_car, umin_car, dyn_car, ...
			                      v0_lead, umin_lead, dyn_lead)
	
	lead_st = slowdown_time(v0_lead, 0, umin_lead, dyn_lead);
	function [ddiff] = ddiff(t) 
		ddiff = distance(v0_lead, min(t,lead_st), umin_lead, dyn_lead) ...
			 -  distance(v0_car, t, umin_car, dyn_car) ...
			 -  1.4* speed(v0_car, t, umin_car, dyn_car);
	end
	tmax_car = slowdown_time(v0_car, 0, umin_car, dyn_car);
	[tt, dmin] = fminbnd(@ddiff, 0, tmax_car);
	dist = -dmin;
end