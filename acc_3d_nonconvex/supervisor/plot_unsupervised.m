lw = 1;
con = constants;

x_out_unsup = x_out; % save unsupervised data
u_out_unsup = u_out;

figure(1)
clf
subplot(411)
hold on
plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
plot(x_out.time, x_out.signals.values(:,3), 'r', 'linewidth', lw)
legend('ACC', 'Lead', 'Location', 'NorthOutSide')
ylabel('$v$')
xlabel('$t$')
yl = ylim;

subplot(412)
hold on
umin = con.umin/(con.g*con.mass);
umax = con.umax/(con.g*con.mass);
plot(u_out.time, u_out.signals.values/(9.82*con.mass), 'b', 'linewidth', lw)
xlabel('$t$')
ylabel('$F_w/mg$')
plot(get(gca,'xlim'), [umax umax], 'g');
plot(get(gca,'xlim'), [umin umin], 'g');
ylim([1.5*con.umin/(con.g*con.mass) 1.5*con.umax/(con.g*con.mass)])
yl = ylim;


subplot(413)
hold on
plot(u_out.time, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1)), 'linewidth', lw)
plot(get(gca,'xlim'), [con.tau_min con.tau_min], 'g');
xlabel('$t$')
ylabel('$\max(3, h/v)$')
yl = ylim;

subplot(414)
hold on
plot(x_out.time, x_out.signals.values(:,2), 'b', 'linewidth', lw)
ylabel('$h$')
xlabel('$t$')