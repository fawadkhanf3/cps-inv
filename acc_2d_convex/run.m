show_plot=1;

con = constants;

dyn_model = get_2d_dyn(con);

control_chain = get_control_sets_2d(dyn_model, con, show_plot);

clf
axis([0 35 0 300]);
hold on
rest = control_chain(end).Set(1)\control_chain(1).Set(1);
plot_poly(rest, repmat([0 0 1], length(rest),1) , 0.7)
plot_poly(control_chain(1), [0 1 0], 0.7)
xc = control_chain(1).Set(1).chebyCenter.x;
text(25, 200, '$C_1$')
xlabel('$v$ [m/s]')
ylabel('$h$ [m]')
xlim([0 35]);
ylim([0 300]);
pause(1)
matlab2tikz('./sec3_Csets.tikz','interpretTickLabelsAsTex',true, ...
		    'width','\figurewidth', 'height', '\figureheight', ...
		    'parseStrings',false, 'showInfo', false, ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=middle, axis y line=middle, every axis x label/.style={at={(current axis.right of origin)},anchor=west},  every axis y label/.style={at={(current axis.north west)},above=2mm}')