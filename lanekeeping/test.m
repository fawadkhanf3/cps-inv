% state is [y phi r]'

con = constants;
dyn = get_dyn(con);

ymax = 0.9; %half lane width
rmax = con.a*con.u0*con.F_yfmax/(con.b^2*con.Car);

domain = Polyhedron('A', [eye(3); -eye(3)], ...
					'b', [3; 90; 2*rmax; 3; 90; 2*rmax]);

safe = Polyhedron('A', [1 0 0;
						-1 0 0;
						0 0  1;
						0 0 -1], ...
				  'b', [ymax;
				  	    ymax;
				  	    rmax;
				  	    rmax] ...
				  );

safe = intersect1(safe,domain);

C = dyn.cinv_oi(safe, 1, 1e-3, 1)

clf;
plot(domain, 'color', 'green', 'alpha', 0.2)
hold on
plot(safe, 'color', 'blue', 'alpha', 0.2)
plot(C, 'color', 'red', 'alpha', 1)