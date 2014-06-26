x_t = x_out.time;
x = x_out.signals.values;
deltaf_t = deltaf_out.time;
deltaf = deltaf_out.signals.values; 

r_road_t = r_road_out.time;
r_road = r_road_out.signals.values; 

figure(1)
clf
subplot(411)
hold on
plot(x_t,x(:,1), 'r'), ylabel('$y$')
plot([0 x_t(end)], [-0.9 -0.9], 'k')
plot([0 x_t(end)], [0.9 0.9], 'k')
subplot(412)
hold on
plot(x_t,x(:,2), 'r'), 
ylabel('$v$')
subplot(413)
hold on
plot(x_t,x(:,3), 'r'), 
ylabel('$\psi$')
subplot(414)
hold on
plot(r_road_t, r_road, 'y')
plot(x_t,x(:,4), 'r'), ylabel('$r$')

matlab2tikz('doc/state.tikz','interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false)
		     % 'width','\figurewidth', 'height', '\figureheight', ...

figure(2)
clf
hold on
plot(deltaf_t,180*deltaf/pi,'r')
ylabel('$\delta_f$')

matlab2tikz('doc/deltaf.tikz','interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false)
		     % 'width','\figurewidth', 'height', '\figureheight', ...