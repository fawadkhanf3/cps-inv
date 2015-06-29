figure(1)
clf; hold on
plot(intersect(safe_set(1:2:end), Polyhedron('H', [0 1 0 100])), 'color', 'green', 'alpha', 0.01)
plot3(x_out.signals.values(:,1), x_out.signals.values(:,2), x_out.signals.values(:,3), 'b')
plot3(x_out_unsup.signals.values(:,1), x_out_unsup.signals.values(:,2), x_out_unsup.signals.values(:,3), 'k--')
xlabel('$v$')
ylabel('$h$')
zlabel('$v_L$')
view([-30 32])

matlab2tikz('trajs.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)