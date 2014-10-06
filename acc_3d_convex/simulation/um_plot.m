lw = 1;
con = constants;

figure(1)
clf
subplot(411)
hold on
plot(x_out.time, x_out.signals.values(:,1), 'b', 'linewidth', lw)
plot(x_out.time, x_out.signals.values(:,3), 'r', 'linewidth', lw)
% plot(kal_out.time, kal_out.signals.values(:,3), 'r--', 'linewidth', lw)
legend('ACC', 'Lead')
% legend('ACC', 'Lead', 'Location', 'NorthEastOutSide')
ylabel('$v$')
xlabel('$t$')

subplot(412)
hold on
plot(x_out.time, x_out.signals.values(:,2), 'linewidth', lw)
plot(get(gca,'xlim'), [3 3], 'g');
ylabel('$h$')
xlabel('$t$')

subplot(413)
hold on
plot(u_out.time, u_out.signals.values/(9.82*con.mass), 'linewidth', lw)
xlabel('$t$')
ylabel('$F_w/mg$')
plot(get(gca,'xlim'), [con.umax/(con.g*con.mass) con.umax/(con.g*con.mass)], 'g');
plot(get(gca,'xlim'), [con.umin/(con.g*con.mass) con.umin/(con.g*con.mass)], 'g');
ylim([1.1*con.umin/(con.g*con.mass) 1.1*con.umax/(con.g*con.mass)])

subplot(414)
hold on
plot(u_out.time, max(0, min(3, x_out.signals.values(:,2)./x_out.signals.values(:,1))), 'linewidth', lw)
plot(get(gca,'xlim'), [con.h_des-con.h_delta con.h_des-con.h_delta], 'g');
xlabel('$t$')
ylabel('$\max(3, h/v)$')

% matlab2tikz('doc/simulink_plots.tikz','interpretTickLabelsAsTex',true, ...
% 		     'parseStrings',false, 'showInfo', false, ...
% 		     'width','\figurewidth', 'height', '\figureheight', ...
% 		    'extraAxisOptions', ...
% 		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')

% ind60 = find(x_out.time>=60, 1);
% ind85 = find(x_out.time>=85, 1);
% ind110 = find(x_out.time>=110, 1);
% figure(2)
% clf
% hold on
% plot(x_out.time(ind60:ind85), x_out.signals.values(ind60:ind85,1), 'b', 'linewidth', lw)
% plot(x_out.time(ind60:ind85), x_out.signals.values(ind60:ind85,3), 'r', 'linewidth', lw)
% ylabel('$v$')
% xlabel('$t$')

% set(gca, 'XTickLabel','')
% legend('ACC','Lead','Location','SouthOutside')
% matlab2tikz('doc/simulink_6085.tikz','interpretTickLabelsAsTex',true, ...
% 		     'parseStrings',false, 'showInfo', false, ...
% 		     'width','\figurewidth', 'height', '\figureheight', ...
% 		    'extraAxisOptions', ...
% 		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')
% clf
% hold on
% plot(x_out.time(ind85:ind110), x_out.signals.values(ind85:ind110,1), 'b', 'linewidth', lw)
% plot(x_out.time(ind85:ind110), x_out.signals.values(ind85:ind110,3), 'r', 'linewidth', lw)
% ylabel('$v$')
% xlabel('$t$')
% set(gca,'XTickLabel','')
% matlab2tikz('doc/simulink_85110.tikz','interpretTickLabelsAsTex',true, ...
% 		     'parseStrings',false, 'showInfo', false, ...
% 		     'width','\figurewidth', 'height', '\figureheight', ...
% 		    'extraAxisOptions', ...
% 		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')


% figure(2)
% clf
% hold on
% colors=cool(length(set_chain));
% for i=length(set_chain):-1:1
% 	plot(intersect1(Polyhedron([ 0 1 0], [200]), set_chain(i)), 'alpha', 0.1, 'color', colors(i,:))
% end
% view([6 18])
% matlab2tikz('doc/setchain.tikz','interpretTickLabelsAsTex',true, ...
% 		     'parseStrings',false, 'showInfo', false, ...
% 		     'width','\figurewidth', 'height', '\figureheight', ...
% 		    'extraAxisOptions', ...
% 		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west}')

% plot3(x_out.signals.values(:,1), x_out.signals.values(:,2), x_out.signals.values(:,3), 'r')