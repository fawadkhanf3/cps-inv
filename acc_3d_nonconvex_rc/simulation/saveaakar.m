FS         = 25;   % Font Size for legend
legendSize = 80; % useless shit

scaleSize = 40;  % Size for the scale

labelSize = 40;  % size for all x and y labels

mark_size = 8;

topoffst = 0.74; % Top offset
botoffst = 0.88; % Bottom offset

finalLegendHeight = 0.08;

xaxis    = 'Time(s)';
yaxis    = '$\tau$';

h         = figure;
set(h, 'position', [100 100 1*500 1*400]);


file = 'car_state_13-41.txt';
M = csvread(file, 1,0);
M(:,1) = (M(:,1)-M(1,1))/10^9;


t_u = u_out.time;
u = u_out.signals.values;

t = x_out.time;
v = x_out.signals.values(:,1);
h = x_out.signals.values(:,2);
vl = x_out.signals.values(:,3);

t70_ind = find(M(:,1) <= 70, 1, 'last')

t_exp = M(1:t70_ind,1)-1;
v_exp = M(1:t70_ind,2);
h_exp = M(1:t70_ind,3);

taud = ones(size(t_exp));

pos3 = [1300, 550, 600, 450];

h = plotData3(h_exp./v_exp, '$\tau^{exp}$', h./v, '$\tau^{sim}$', t_exp, t);
set(h, 'position', pos3);   
if 1
    savename = 'newfig.eps'
    print(h, savename, '-depsc2');
end


% // figure(1); clf
% // hold on
% // plot(t_exp, h_exp./v_exp, 'r')
% // plot(t, h./v, '--k')

% // plot([0 70], [1 1], 'k--')
% // axis([0 70 0 5])