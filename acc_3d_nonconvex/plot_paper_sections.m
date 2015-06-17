load case3

C1_c3 = C1;
C2_c3 = C2;

load case4;

C1_c4 = C1;
C2_c4 = C2;

figure; hold on
ipoly = Polyhedron('He', [0 0 1 10])
plot(projection(intersect(C1_c3, ipoly), [1 2]), 'color', [0 0.5 0], 'alpha', 0.05)
plot(projection(intersect(intersect(C2_c3, Polyhedron('H', [0 1 0 200])), ipoly), [1 2]), 'color', [0 0 0.5], 'alpha', 0.05)
xlabel('$v$')
ylabel('$h$')
grid off


matlab2tikz('plots/pcis_case3_isect.tikz', 'interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false, ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west},  every axis y label/.style={at={(current axis.north west)},anchor=south}')



clf; hold on
ipoly = Polyhedron('He', [0 0 1 10])
plot(projection(intersect(C1_c3, ipoly), [1 2]), 'color', 'gray', 'alpha', 0.05, 'linestyle', 'none')
plot(projection(intersect(intersect(C2_c3, Polyhedron('H', [0 1 0 200])), ipoly), [1 2]), 'color', 'gray', 'alpha', 0.05, 'linestyle', 'none')
plot(projection(intersect(C1_c4, ipoly), [1 2]), 'color', [0 0.5 0], 'alpha', 0.05)
plot(projection(intersect(intersect(C2_c4, Polyhedron('H', [0 1 0 200])), ipoly), [1 2]), 'color', [0 0 0.5], 'alpha', 0.05)
xlabel('$v$')
ylabel('$h$')
grid off


matlab2tikz('plots/pcis_case4_isect.tikz', 'interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false, ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west},  every axis y label/.style={at={(current axis.north west)},anchor=south}')
