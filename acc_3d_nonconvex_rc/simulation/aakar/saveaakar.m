  file = 'car_state_13-41.txt';
  M = csvread(file, 1,0);
  M(:,1) = (M(:,1)-M(1,1))/10^9;


t_u = u_out.time
u = u_out.signals.values

t = x_out.time
v = x_out.signals.values(:,1);
h = x_out.signals.values(:,2);
vl = x_out.signals.values(:,3);

t_exp = M(:,1);
v_exp = M(:,2);