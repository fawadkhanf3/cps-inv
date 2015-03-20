lw = 1;

t60 = find(x_out.time < 60, 1, 'last');
t80 = find(x_out.time >= 75);

figure(1)
clf
subplot(411)
hold on
plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
plot(x_out.time(1:t60), x_out.signals.values(1:t60,3), 'r', 'linewidth', lw)
plot(x_out.time(t80:end), x_out.signals.values(t80:end,3), 'r', 'linewidth', lw)
% plot(kal_out.time, kal_out.signals.values(:,3), 'r--', 'linewidth', lw)
% legend('ACC', 'Lead')
% legend('ACC', 'Lead', 'Location', 'NorthOutSide')
ylabel('$v$')
xlabel('$t$')

subplot(412)
hold on
plot(x_out.time, x_out.signals.values(:,2), 'linewidth', lw)
plot(get(gca,'xlim'), [con.h_min con.h_min], 'g');
ylabel('$h$')
xlabel('$t$')

subplot(413)
hold on
plot(u_out.time, u_out.signals.values, 'linewidth', lw)
xlabel('$t$')
ylabel('$F_w/mg$')
plot(get(gca,'xlim'), [con.umax con.umax], 'g');
plot(get(gca,'xlim'), [con.umin con.umin], 'g');
ylim([1.1*con.umin 1.1*con.umax])

subplot(414)
hold on
plot(u_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))), 'linewidth', lw)
plot(get(gca,'xlim'), [con.tau_des con.tau_des], 'g');
xlabel('$t$')
ylabel('$\min(3, h/v)$')

matlab2tikz('3d_sim.tikz','interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')