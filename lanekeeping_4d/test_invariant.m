% state is [y v phi r]'

con = constants;
dyn = get_dyn(con);

ymax = 0.9; %half lane width
rmax = con.a*con.u0*con.F_yfmax/(con.b^2*con.Car);

domain = Polyhedron('A', [eye(4); -eye(4)], ...
					'b', [2*ymax; 1; 0.15; 2*rmax; 2*ymax; 1; 0.15; 2*rmax]);

safe = Polyhedron('A', [1  0 0 0;
						-1 0 0 0], ...
				  'b', [ymax;
				  	    ymax] ...
				  );

safe = intersect1(safe,domain);

% C = dyn.cinv_oi(safe, 5, 0, 0, 1);

% plot some projections of C
figure(1)
clf
plot(projection(intersect(C, Polyhedron('Ae', [1 0 0 0], 'be', [0])), [2 3 4]), 'alpha', 0.5)
xlabel('$v$')
ylabel('$\psi$')
zlabel('$r$')
matlab2tikz('doc/poly1.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

plot(projection(intersect(C, Polyhedron('Ae', [0 1 0 0], 'be', [0])), [1 3 4]), 'alpha', 0.5)
xlabel('$y$')
ylabel('$\psi$')
zlabel('$r$')
matlab2tikz('doc/poly2.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

plot(projection(intersect(C, Polyhedron('Ae', [0 0 1 0], 'be', [0])), [1 2 4]), 'alpha', 0.5)
xlabel('$y$')
ylabel('$v$')
zlabel('$r$')
matlab2tikz('doc/poly3.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

plot(projection(intersect(C, Polyhedron('Ae', [0 0 0 1], 'be', [0])), [1 2 3]), 'alpha', 0.5)
xlabel('$y$')
ylabel('$v$')
zlabel('$\psi$')
matlab2tikz('doc/poly4.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)
