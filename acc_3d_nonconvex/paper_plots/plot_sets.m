% this requires matlab2tikz v 0.6.0

load case3

figure; hold on
plot(C1(1:2:end), 'color', [0 0.5 0], 'alpha', 0.05)
plot(intersect(C2(1:2:end), Polyhedron('H', [0 1 0 200])), 'color', [0 0 0.5], 'alpha', 0.05)
xlabel('$v$')
ylabel('$h$')
zlabel('$v_L$')
view([-20 18])
grid off
zlim([0 35])

matlab2tikz('tikz/pcis_case3_invset.tikz','interpretTickLabelsAsTex',true, 'noSize',true, ...
 			'parseStrings',false, 'extraAxisOptions', ...
		    'width=\figurewidth, height=\figureheight')

load case4

figure; hold on
plot(C1(1:2:end), 'color', [0 0.5 0], 'alpha', 0.05)
plot(intersect(C2(1:2:end), Polyhedron('H', [0 1 0 200])), 'color', [0 0 0.5], 'alpha', 0.05)
xlabel('$v$')
ylabel('$h$')
zlabel('$v_L$')
view([-20 18])
grid off
zlim([0 35])

matlab2tikz('tikz/pcis_case4_invset.tikz','interpretTickLabelsAsTex',true, 'noSize',true, ...
 			'parseStrings',false, 'extraAxisOptions', ...
		    'width=\figurewidth, height=\figureheight')
