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
plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
plot(x_out.time, x_out.signals.values(:,3), 'r', 'linewidth', lw)

ylim([0 30])
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
plot(u_out.time, u_out.signals.values/(9.82*con.mass), 'linewidth', lw)
ylim([1.1*con.umin/(con.g*con.mass) 1.1*con.umax/(con.g*con.mass)])

subplot(414)
hold on
plot(x_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))), 'linewidth', lw)
plot(get(gca,'xlim'), [con.tau_des con.tau_des], 'g');
plot(get(gca,'xlim'), [con.tau_min con.tau_min], 'r');
xlabel('$t$')
ylabel('$\min(3, h/v)$')


