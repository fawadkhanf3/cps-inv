figure; hold on
plot(C1(1:2:end), 'color', [0 0.5 0], 'alpha', 0.05)
plot(intersect(C2(1:2:end), Polyhedron('H', [0 1 0 200])), 'color', [0 0 0.5], 'alpha', 0.05)
xlabel('$v$')
ylabel('$h$')
zlabel('$v_L$')
view([-20 18])
grid off
ylim([0 35])

if case_nr == 3
	filename = 'plots/pcis_case3_invset.tikz'
else
	filename = 'plots/pcis_case4_invset.tikz'
end
matlab2tikz(filename,'interpretTickLabelsAsTex',true, 'width','\figurewidth', 'height', '\figureheight', 'parseStrings',false, 'showInfo', false)

figure; hold on
ipoly = Polyhedron('He', [0 0 1 10])
plot(projection(intersect(C1, ipoly), [1 2]), 'color', [0 0.5 0], 'alpha', 0.05)
plot(projection(intersect(intersect(C2, Polyhedron('H', [0 1 0 200])), ipoly), [1 2]), 'color', [0 0 0.5], 'alpha', 0.05)
xlabel('$v$')
ylabel('$h$')
grid off

if case_nr == 3
	filename = 'plots/pcis_case3_isect.tikz'
else
	filename = 'plots/pcis_case4_isect.tikz'
end

matlab2tikz(filename, 'interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false, ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west},  every axis y label/.style={at={(current axis.north west)},anchor=south}')
