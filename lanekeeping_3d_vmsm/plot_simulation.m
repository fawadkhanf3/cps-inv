x_t_4d = x_out_4d.time;
x_4d = x_out_4d.signals.values;
rdot_car_t_4d = rdot_car_out_4d.time;
rdot_car_4d = rdot_car_out_4d.signals.values; 

x_t_3d = x_out_3d.time;
x_3d = x_out_3d.signals.values;
rdot_car_t_3d = rdot_car_out_3d.time;
rdot_car_3d = rdot_car_out_3d.signals.values; 


r_road_t = r_road_out.time;
r_road = r_road_out.signals.values; 

figure(1)
clf
subplot(411)
hold on
plot(x_t_4d,x_4d(:,1), 'r'), ylabel('$y$')
plot(x_t_3d,x_3d(:,1), 'b'), ylabel('$y$')
plot([0 x_t_3d(end)], [-0.9 -0.9], 'k')
plot([0 x_t_3d(end)], [0.9 0.9], 'k')
legend('4 state', '3 state')
subplot(412)
hold on
plot(x_t_4d,x_4d(:,2), 'r'), 
ylabel('$v$')
subplot(413)
hold on
plot(x_t_4d,x_4d(:,3), 'r'), 
plot(x_t_3d,x_3d(:,2), 'b'), 
ylabel('$\psi$')
subplot(414)
hold on
plot(r_road_t, r_road, 'y')
plot(x_t_4d,x_4d(:,4), 'r'), ylabel('$r$')
plot(x_t_3d,x_3d(:,3), 'b'), ylabel('$r$')

matlab2tikz('doc/state.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

figure(2)
clf
hold on
plot(rdot_car_t_4d,rdot_car_4d,'r')
plot(rdot_car_t_3d,rdot_car_3d,'b')
ylabel('$r_{dot}$')

matlab2tikz('doc/rdot.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)