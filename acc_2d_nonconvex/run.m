show_plot=0;

con = constants;

dyn_model = get_2d_dyn(con);

% [c_vec1 cvec2] = get_control_sets_2d(dyn_model, con, show_plot);

clf
axis([0 35 0 300]);
hold on
plot_poly(cvec2(end-1:end), [0 0 1; 0 0 1])
plot_poly(cvec2(1:end-2), cool(length(cvec2)-2));
plot_poly(c_vec1, hot(length(c_vec1)));
plot_poly(c_vec1(1), [0 1 0])
xlabel('$v$ [m/s]')
ylabel('$h$ [m]')
xlim([0 35]);
ylim([0 300]);
pause(1)
matlab2tikz('./sec3_Csets.tikz','interpretTickLabelsAsTex',true, ...
		    'width','\figurewidth', 'height', '\figureheight', ...
		    'parseStrings',false, 'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=middle, axis y line=middle, every axis x label/.style={at={(current axis.right of origin)},anchor=west},  every axis y label/.style={at={(current axis.north west)},above=2mm}')