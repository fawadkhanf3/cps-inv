% parameters

% plot M2 area
plot_M2 = 1;

% before or after 5 s
plot_after_5s = 1;

% alpha for M2 area
alpha = 0.05

% linewidth
lw = 1;

% filename 
filename = 'sim_case3_cutin.tikz';

t5 = find(x_out.time >= 5, 1, 'first');

figure(1)
clf
subplot(411)
hold on

if plot_after_5s
	plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
	plot(x_out.time(t5:end), x_out.signals.values(t5:end,3), 'r', 'linewidth', lw)
else
	plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
	plot(x_out.time(1:t5-1), x_out.signals.values(1:t5-1,3), 'r', 'linewidth', lw)
end
ylim([0 30])
legend('ACC', 'Lead', 'Location', 'NorthOutSide')
ylabel('$v$')
xlabel('$t$')

subplot(412)
hold on
if plot_after_5s
	plot(x_out.time(t5:end), x_out.signals.values(t5:end,2), 'linewidth', lw)
else
	plot(x_out.time(1:t5-1), x_out.signals.values(1:t5-1,2), 'linewidth', lw)
end

xlim([0 20])
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
plot(u_out.time, u_out.signals.values/(9.82*con.mass), 'linewidth', lw)
ylim([1.1*con.umin/(con.g*con.mass) 1.1*con.umax/(con.g*con.mass)])

subplot(414)
hold on
plot(u_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))), 'linewidth', lw)
plot(get(gca,'xlim'), [con.tau_des con.tau_des], 'g');
plot(u_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))), 'linewidth', lw)
xlabel('$t$')
ylabel('$\min(3, h/v)$')

if plot_M2

	M2_idx = x_out.signals.values(:,2) <= con.v_des * con.tau_des;
	differ = M2_idx(2:end) - M2_idx(1:end-1);
	change_plus = x_out.time(1+find(differ == 1));
	change_minus = x_out.time(1+find(differ == -1));
	if M2_idx(1) == 1
		change_plus = [0; change_plus];
	end
	if M2_idx(end) == 1
		change_minus = [change_minus; x_out.time(end)];
	end


	subplot(411)
	yl = ylim;
	for i=1:length(change_plus)
		xv = [change_plus(i) change_minus(i) change_minus(i) change_plus(i)];
		yv = [yl(1) yl(1) yl(2) yl(2)];
		pp = patch(xv,yv,[1 0 0]);
		set(pp, 'facealpha', alpha, 'LineStyle', 'none')
	end

	subplot(412)
	yl = ylim;
	for i=1:length(change_plus)
		xv = [change_plus(i) change_minus(i) change_minus(i) change_plus(i)];
		yv = [yl(1) yl(1) yl(2) yl(2)];
		pp = patch(xv,yv,[1 0 0]);
		set(pp, 'facealpha', alpha, 'LineStyle', 'none')
	end

	subplot(414)
	yl = ylim;
	for i=1:length(change_plus)
		xv = [change_plus(i) change_minus(i) change_minus(i) change_plus(i)];
		yv = [yl(1) yl(1) yl(2) yl(2)];
		pp = patch(xv,yv,[1 0 0]);
		set(pp, 'facealpha', alpha, 'LineStyle', 'none')
	end
end


matlab2tikz(filename,'interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')