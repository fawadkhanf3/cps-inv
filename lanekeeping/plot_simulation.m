x_t = x_out.time;
x = x_out.signals.values;
rdot_car_t = rdot_car_out.time;
rdot_car = rdot_car_out.signals.values; 
r_road_t = r_road_out.time;
r_road = r_road_out.signals.values; 

figure(1)
clf
subplot(311)
plot(x_t,x(:,1)), ylabel('$y$')
subplot(312)
hold on
plot(x_t,x(:,2)), 
ylabel('$\psi$')
subplot(313)
hold on
plot(r_road_t, r_road, 'r')
plot(x_t,x(:,3)), ylabel('$r$')

matlab2tikz('doc/state.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

figure(2)
clf
hold on
plot(rdot_car_t,rdot_car,'b')
legend('$r_{dot}$', 'location', 'northwest')

matlab2tikz('doc/rdot.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)