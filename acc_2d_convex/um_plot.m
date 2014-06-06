con = constants;
figure(1)
clf
hold on
subplot(411)
plot(x_out.time, x_out.signals.values(:,1))
xlabel('Velocity')
subplot(412)
plot(x_out.time, x_out.signals.values(:,2))
xlabel('Headway')
subplot(413)
plot(u_out.time, u_out.signals.values/(9.82*con.mass))
xlabel('Input')
subplot(414)
plot(u_out.time, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1)))
xlabel('Time headway')

figure(2)
clf
hold on
colors=cool(length(control_chain));
for i=length(control_chain):-1:1
	plot(control_chain(i), 'color', colors(i,:), 'linestyle', 'none')
end
plot(x_out.signals.values(:,1), x_out.signals.values(:,2))