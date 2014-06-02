con = constants;
figure(1)
clf
subplot(411)
hold on
plot(x_out.time, x_out.signals.values(:,1), 'b')
plot(x_out.time, x_out.signals.values(:,3), 'r')
legend('Following', 'Lead')
xlabel('Velocities')
subplot(412)
plot(x_out.time, x_out.signals.values(:,2))
xlabel('Headway')
subplot(413)
plot(u_out.time, u_out.signals.values/(9.82*con.mass))
xlabel('Input')
subplot(414)
hold on
plot(u_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))))
plot(get(gca,'xlim'), [con.h_des-con.h_delta con.h_des-con.h_delta], 'r');
xlabel('Input')

figure(2)
clf
hold on
colors=cool(length(set_chain));
for i=length(set_chain):-1:1
	plot(set_chain(i), 'color', colors(i,:), 'alpha', 0.1)
end
plot3(x_out.signals.values(:,1), x_out.signals.values(:,2), x_out.signals.values(:,3), 'r')