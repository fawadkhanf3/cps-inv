show_plot=1;

con = constants;

dyn_model = get_2d_dyn(con);

%% V-H State space
VH = Polyhedron([eye(2); -eye(2)], [con.v_max; con.d_max; -con.v_min; -con.d_min]);

%% Safe area
S1 = intersect1(VH, Polyhedron('A', [1 -1], 'b', [0]));

%%% Desired areas
G2A = [con.h_des  -1;
   1  	  0];

G2b = [0; 
   con.v_des];

%% Good headway
G2 = intersect1(VH, Polyhedron('A', G2A, 'b', G2b));

%% Use inside-out approach starting with V0
C0 = intersect1(G2, Polyhedron([1 0; -1 0], [con.v_lead; -con.v_lead])); 
C1 = dyn_model.cinv_io(G2, C0, show_plot);

control_chain = [C1];

for i=1:10
	control_chain = [control_chain intersect1(S1, dyn_model.pre(control_chain(end) )) ];
end

save('control_chain.mat', 'control_chain')

% clf
% axis([0 35 0 200]);
% hold on

% plot(S1, 'color', 'red', 'alpha', 0.1)
% plot(G2, 'color', 'blue', 'alpha', 0.3)
% plot(C1, 'color', 'green', 'alpha', 0.9)

% for i=2:10
% 	plot(control_chain(i)\control_chain(i-1), 'color', 'green', 'alpha', 0.2, 'linestyle', 'none')
% end

% text(10, 150, '$C$')
% text(22, 42, '$G$')
% text(30, 80, '$S$')
% text(27, 170, '$S\cap Pre(C)$')


% xlabel('$v$')
% ylabel('$h$')

% matlab2tikz('2d_plot.tikz','interpretTickLabelsAsTex',true, ...
% 		     'width','\figurewidth', 'height', '\figureheight', ...
% 		     'parseStrings',false, 'showInfo', false, ...
% 		    'extraAxisOptions', ...
% 		    'xmajorgrids=false, ymajorgrids=false, axis x line=bottom, axis y line=left, every axis x label/.style={at={(current axis.south east)},anchor=west},  every axis y label/.style={at={(current axis.north west)},anchor=south}')
