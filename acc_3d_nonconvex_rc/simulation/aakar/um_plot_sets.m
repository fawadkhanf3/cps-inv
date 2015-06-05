clear all;
load data

%%%%%%%%%%%%%%%% Plot trajectories %%%%%%%%%%%%%%%%
figure(1); clf; hold on

clf
subplot(411)
hold on
plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
plot(x_out.time, x_out.signals.values(:,3), 'r', 'linewidth', lw)
legend('ACC', 'Lead')
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

matlab2tikz('simulation.tikz','interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')

%%%%%%%%%%%%%%%% Plot full cinv set %%%%%%%%%%%%%%%%
figure(2); clf; hold on

% plot trajectories
t_ind = find(M(:,1) <= 70, 1, 'last');
plot3(M(5:t_ind,2), M(5:t_ind,3), M(5:t_ind,4), 'linewidth', 1);

%  plot3(x_out.signals.values(1:10:end,1), x_out.signals.values(1:10:end,2), x_out.signals.values(1:10:end,3), 'linewidth', 1);

% plot sets on top
plot(intersect(S1, poly10), 'color', 'red', 'alpha', 0.1)
plot(intersect(goal, poly10), 'color', 'blue', 'alpha', 0.2)

for i=1:4:length(set_mat{1})
	plot(intersect(set_mat{1}(i), poly10), 'color', 'green', 'alpha', 0.1)
end
for j = 1:4:length(set_mat{end})
	plot(intersect(set_mat{end}(j), poly10), 'color', 'green', 'alpha', 0.06, 'linestyle', 'none')
end

text(0.3, 9, 2, '$C_0$')
text(2, 3, 0.1, '$G$')
text(3, 4, 1, '$S$')
text(3, 5, 3, '$S \cap Pre(C_0)$')


xlabel('$v$')
ylabel('$h$')
zlabel('$v_L$')
view([-44 28])

matlab2tikz('set.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

