con = constants;
figure(1)
clf
hold on
subplot(311)
plot(x_out.time, x_out.signals.values(:,1))
xlabel('Velocity')
subplot(312)
plot(x_out.time, x_out.signals.values(:,2))
xlabel('Headway')
subplot(313)
plot(u_out.time, u_out.signals.values/(9.82*con.mass))
xlabel('Input')

figure(2)
clf
hold on
colors=cool(length(vp));
for i=length(vp):-1:1
	plot(vp(i), 'color', colors(i,:), 'linestyle', 'none')
end
plot(x_out.signals.values(:,1), x_out.signals.values(:,2))