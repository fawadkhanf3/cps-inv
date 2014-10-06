lw = 1;
con = constants;

% construct vectors of different signs
differ = box_out.signals.values(2:end) - box_out.signals.values(1:end-1);
change_plus = box_out.time(1+find(differ == 1));
change_minus = box_out.time(1+find(differ == -1));
if box_out.signals.values(1) == 1
	change_plus = [0; change_plus];
end
if box_out.signals.values(end) == 1
	change_minus = [change_minus; box_out.time(end)];
end


figure(1)
clf
subplot(311)
hold on
plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
plot(x_out.time, x_out.signals.values(:,3), 'r', 'linewidth', lw)
% legend('ACC', 'Lead')
legend('ACC', 'Lead', 'Location', 'NorthEastOutSide')
ylabel('$v$')
xlabel('$t$')
yl = ylim;
for i=1:length(change_plus)
	xv = [change_plus(i) change_minus(i) change_minus(i) change_plus(i)];
	yv = [yl(1) yl(1) yl(2) yl(2)];
	pp = patch(xv,yv,[1 0 0]);
	set(pp, 'facealpha', 0.1, 'LineStyle', 'none')
end

% subplot(312)
% hold on
% plot(x_out.time, x_out.signals.values(:,2), 'r', 'linewidth', lw)
% plot(get(gca,'xlim'), [3 3], 'g');
% ylabel('$h$')
% xlabel('$t$')

subplot(312)
hold on
umin = con.umin/(con.g*con.mass);
umax = con.umax/(con.g*con.mass);
plot(u_out.time, u_out.signals.values/(9.82*con.mass), 'b', 'linewidth', lw)
% plot(u_des_out.time, u_des_out.signals.values/(9.82*con.mass), 'b--', 'linewidth', lw)
% legend('Supervised', 'Desired', 'Location', 'NorthEastOutSide')
xlabel('$t$')
ylabel('$F_w/mg$')
plot(get(gca,'xlim'), [umax umax], 'g');
plot(get(gca,'xlim'), [umin umin], 'g');
ylim([1.1*con.umin/(con.g*con.mass) 1.1*con.umax/(con.g*con.mass)])
yl = ylim;
for i=1:length(change_plus)
	xv = [change_plus(i) change_minus(i) change_minus(i) change_plus(i)];
	yv = [yl(1) yl(1) yl(2) yl(2)];
	pp = patch(xv,yv,[1 0 0]);
	set(pp, 'facealpha', 0.1, 'LineStyle', 'none')
end


subplot(313)
hold on
plot(u_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))), 'linewidth', lw)
plot(get(gca,'xlim'), [con.h_des-con.h_delta con.h_des-con.h_delta], 'g');
xlabel('$t$')
ylabel('$\max(3, h/v)$')
yl = ylim;
for i=1:length(change_plus)
	xv = [change_plus(i) change_minus(i) change_minus(i) change_plus(i)];
	yv = [yl(1) yl(1) yl(2) yl(2)];
	pp = patch(xv,yv,[1 0 0]);
	set(pp, 'facealpha', 0.1, 'LineStyle', 'none')
end

matlab2tikz('doc/gabor_without.tikz','interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')

% figure(2)
% clf
% hold on
% colors=cool(length(set_chain));
% for i=length(set_chain):-1:1
% 	plot(set_chain(i), 'color', colors(i,:), 'alpha', 0.1)
% end
% plot3(x_out.signals.values(:,1), x_out.signals.values(:,2), x_out.signals.values(:,3), 'r')