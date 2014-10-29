lw = 1;

figure(1)
clf
subplot(411)
hold on
plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
plot(x_out.time, x_out.signals.values(:,3), 'r', 'linewidth', lw)
% plot(kal_out.time, kal_out.signals.values(:,3), 'r--', 'linewidth', lw)
% legend('ACC', 'Lead')
legend('ACC', 'Lead', 'Location', 'NorthOutSide')
ylabel('$v$')
xlabel('$t$')

subplot(412)
hold on
plot(x_out.time, x_out.signals.values(:,2), 'linewidth', lw)
plot(get(gca,'xlim'), [3 3], 'g');
ylabel('$h$')
xlabel('$t$')

subplot(413)
hold on
plot(u_out.time, u_out.signals.values/(9.82*con.mass), 'linewidth', lw)
xlabel('$t$')
ylabel('$F_w/mg$')
plot(get(gca,'xlim'), [con.umax/(con.g*con.mass) con.umax/(con.g*con.mass)], 'g');
plot(get(gca,'xlim'), [con.umin/(con.g*con.mass) con.umin/(con.g*con.mass)], 'g');
ylim([1.1*con.umin/(con.g*con.mass) 1.1*con.umax/(con.g*con.mass)])

subplot(414)
hold on
plot(u_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))), 'linewidth', lw)
plot(get(gca,'xlim'), [con.tau_min con.tau_min], 'g');
xlabel('$t$')
ylabel('$\max(3, h/v)$')

matlab2tikz('simulink_plots.tikz','interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')