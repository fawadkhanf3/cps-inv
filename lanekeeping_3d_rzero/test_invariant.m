% state is [y phi r]'

con = constants;
dyn = get_dyn(con);
dyn_m = get_dyn_m(con);

ymax = 0.9; %half lane width
rmax = 2*ymax;

domain = Polyhedron('A', [eye(3); -eye(3)], ...
					'b', [2*ymax; 0.15; 2*rmax; 2*ymax; 0.15; 2*rmax]);

safe = Polyhedron('A', [1 0 0;
						-1 0 0], ...
				  'b', [ymax;
				  	    ymax] ...
				  );

safe = intersect1(safe,domain);
Cinv = dyn.cinv_oi(safe);
Cinv_m = dyn_m.cinv_oi(safe);

clf;
plot(safe, 'color', 'blue', 'alpha', 0.05, 'LineAlpha', 0.5)
hold on
plot(Cinv, 'color', 'red', 'alpha', 0.3, 'LineAlpha', 0.5)
plot(Cinv_m, 'color', 'green', 'alpha', 0.3, 'LineAlpha', 0.5)
xlabel('$y$')
ylabel('$\psi$')
zlabel('$r$')