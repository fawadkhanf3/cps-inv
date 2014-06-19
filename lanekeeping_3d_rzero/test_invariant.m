% state is [y phi r]'

con = constants;
dyn = get_dyn(con);

ymax = 0.9; %half lane width
rmax = con.a*con.u0*con.F_yfmax/(con.b^2*con.Car);

domain = Polyhedron('A', [eye(3); -eye(3)], ...
					'b', [2*ymax; 0.15; 2*rmax; 2*ymax; 0.15; 2*rmax]);

safe = Polyhedron('A', [1 0 0;
						-1 0 0], ...
				  'b', [ymax;
				  	    ymax] ...
				  );

safe = intersect1(safe,domain);

V = safe;

% Run outside-in algo
rel_vol = inf;
iter = 1;

while rel_vol > 1e-5
	V_prim = intersect1(V, dyn.solve_feasible(V));

	vol1 = volume1(V);
	vol2 = volume1(V_prim);
	rel_vol = (vol1-vol2)/vol1;

	V = V_prim;

	% Record a movie
	% clf
	% hold on
	% plot(safe, 'color', 'blue', 'alpha', 0.2, 'LineAlpha', 0.5);
	% plot(V, 'color', 'red', 'alpha', 0.5, 'LineAlpha', 0.5);
	% axis off
	% drawnow;
	% mov(iter) = getframe(gcf);

	iter = iter+1;
end

% movie2avi(mov, 'doc/outside-in.avi', 'compression', 'None', 'fps', 2);

clf;
plot(safe, 'color', 'blue', 'alpha', 0.2, 'LineAlpha', 0.5)
hold on
plot(C, 'color', 'red', 'alpha', 0.5, 'LineAlpha', 0.5)
xlabel('$y$')
ylabel('$\psi$')
zlabel('$r$')

matlab2tikz('doc/invariant.tikz','interpretTickLabelsAsTex',true, ...
         'parseStrings',false, 'showInfo', false)