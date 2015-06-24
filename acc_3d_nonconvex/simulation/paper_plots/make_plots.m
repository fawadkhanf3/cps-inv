clear all;

% plot mode area
plot_mode_area = 1;

% alpha for M2 area
alpha = 0.05;

% linewidth
lw = 1;

% maxh
maxh = 200;

% datasets to load
dataset1 = 'simulink.mat';
dataset2 = 'simulink.mat';

% export filename 
filename = 'sim_case3';

% load constants
con = constants_normal;

%%%%%%%%%%%% PLOT FIRST DATASET %%%%%%%%%%%%%%%%%%

load(dataset1)

h_intervals = extract_intervals(x_out.signals.values(:,2) < maxh);
res_x = floor(length(x_out.time)/1000);
res_u = floor(length(u_out.time)/1000);

figure(1); clf; hold on
set1 = plot(x_out.time(1:res_x:end), x_out.signals.values(1:res_x:end,1), 'b', 'linewidth', lw);
for i=1:size(h_intervals, 1)
	lead = plot(x_out.time(h_intervals(i,1):res_x:h_intervals(i,2)), x_out.signals.values(h_intervals(i,1):res_x:h_intervals(i,2),3), 'r', 'linewidth', lw);
end

figure(2); clf; hold on
for i=1:size(h_intervals, 1)
	plot(x_out.time(h_intervals(i,1):res_x:h_intervals(i,2)), x_out.signals.values(h_intervals(i,1):res_x:h_intervals(i,2),2), 'linewidth', lw)
end

figure(3); clf; hold on
plot(u_out.time(1:res_u:end), u_out.signals.values(1:res_u:end)/(con.g*con.mass), 'linewidth', lw)

figure(4); clf; hold on
plot(x_out.time(1:res_x:end), max(0, min(3, x_out.signals.values(1:res_x:end,2)./x_out.signals.values(1:res_x:end,1))), 'linewidth', lw)


%%%%%%%%%%%% PLOT SECOND DATASET %%%%%%%%%%%%%%%%%%

load(dataset2)

h_intervals = extract_intervals(x_out.signals.values(:,2) < maxh);
res_x = floor(length(x_out.time)/1000);
res_u = floor(length(u_out.time)/1000);

figure(1)
set2 = plot(x_out.time(1:res_x:end), x_out.signals.values(1:res_x:end,1), 'k--', 'linewidth', lw);

figure(2)
for i=1:size(h_intervals, 1)
	plot(x_out.time(h_intervals(i,1):res_x:h_intervals(i,2)), x_out.signals.values(h_intervals(i,1):res_x:h_intervals(i,2),2), 'k--', 'linewidth', lw)
end

figure(3)
plot(u_out.time(1:res_u:end), u_out.signals.values(1:res_u:end)/(con.g*con.mass), 'k--', 'linewidth', lw)

figure(4)
plot(x_out.time(1:res_x:end), max(0, min(3, x_out.signals.values(1:res_x:end,2)./x_out.signals.values(1:res_x:end,1))), 'k--', 'linewidth', lw)

%%%%%%%%%%%% ADD LABELS, ADJUST LIMITS %%%%%%%%%%%%%%%%%%%%

figure(1)
ylabel('$v$')
xlabel('$t$')
legend([set1 set2 lead], 'ACC-Simulink', 'ACC-Carsim', 'Lead', 'Location', 'NorthOutSide')
ylim([0 30])
h = plot(get(gca,'xlim'), [con.v_des con.v_des], '--', 'color', [0 0.7 0]);
uistack(h, 'bottom')

figure(2)
ylabel('$h$')
xlabel('$t$')
ylim([0 50])

figure(3)
xlabel('$t$')
ylabel('$F_w/mg$')
h = plot(get(gca,'xlim'), [con.umax/(con.g*con.mass) con.umax/(con.g*con.mass)], 'color', [0 0.7 0]);
uistack(h, 'bottom')
h = plot(get(gca,'xlim'), [con.umin/(con.g*con.mass) con.umin/(con.g*con.mass)], 'color', [0 0.7 0]);
uistack(h, 'bottom')
ylim([-0.35 0.25])

figure(4)
xlabel('$t$')
ylabel('$\min(3, h/v)$')
ylim([0.5 3.1])
h = plot(get(gca,'xlim'), [con.tau_des con.tau_des], '--', 'color', [0 0.7 0]);
uistack(h, 'bottom')
h = plot(get(gca,'xlim'), [con.tau_min con.tau_min], 'color', [0 0.7 0]);
uistack(h, 'bottom')

%%%%%%%%%%%% PLOT MODE REGIONS %%%%%%%%%%%%%%%%%%%%

if plot_mode_area

	mode_intervals = extract_intervals(x_out.signals.values(:,2) <= con.v_des * con.tau_des);

	for i=1:size(mode_intervals, 1)
		xv = [x_out.time(mode_intervals(i,1)) x_out.time(mode_intervals(i,2)) x_out.time(mode_intervals(i,2)) x_out.time(mode_intervals(i,1))];

		figure(1)
		yl = ylim;
		yv = [yl(1) yl(1) yl(2) yl(2)];
		pp = patch(xv,yv,[1 0 0]);
		set(pp, 'facealpha', alpha, 'EdgeAlpha', 0)

		figure(2)
		yl = ylim;
		yv = [yl(1) yl(1) yl(2) yl(2)];
		pp = patch(xv,yv,[1 0 0]);
		set(pp, 'facealpha', alpha, 'EdgeAlpha', 0)

		figure(4)
		yl = ylim;
		yv = [yl(1) yl(1) yl(2) yl(2)];
		pp = patch(xv,yv,[1 0 0]);
		set(pp, 'facealpha', alpha, 'EdgeAlpha', 0)
	end
end
%%%%%%%%%%%% EXPORT TIKZ %%%%%%%%%%%%%%%%%%%%

for i=1:4
	figure(i)
	matlab2tikz(strcat(filename, '-', num2str(i), '.tikz'),'interpretTickLabelsAsTex',true, ...
		     'parseStrings',false, 'showInfo', false, ...
		     'noSize',true, ...
		    'extraAxisOptions', ...
		    'width=\figurewidth, height=\figureheight, xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')
end