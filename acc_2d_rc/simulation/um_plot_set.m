clf
axis([0 35 0 200]);
hold on

plot(S1, 'color', 'red', 'alpha', 0.1, 'linestyle', 'none')
plot(G2, 'color', 'blue', 'alpha', 0.3, 'linestyle', 'none')
plot(C1, 'color', 'green', 'alpha', 0.9, 'linestyle', 'none')

for i=2:10
	plot(control_chain(i)\control_chain(i-1), 'color', 'green', 'alpha', 0.2, 'linestyle', 'none')
end

text(10, 150, '$C$')
text(23, 42, '$G$')
text(30, 60, '$S$')
text(27, 170, '$S\cap Pre(C)$')


xlabel('$v$')
ylabel('$h$')

matlab2tikz('2d_plot.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false, ...
		    'extraAxisOptions', ...
		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west},  every axis y label/.style={at={(current axis.north west)},anchor=south}')