con = constants;
pwadyn = get_pw_dyn(con);
simple_dyn = get_simple_dyn(con);

VH = pwadyn.domain;
%Safe set
S1 = intersect(VH, Polyhedron([1 -1 0; 0 -1 0], [0; -3]));
% Goal set
GA = [con.h_des-con.h_delta -1 0; 1 0 0];
Gb = [0; con.v_des+con.v_delta];
goal = intersect1(S1, Polyhedron('A', GA, 'b', Gb));

cinv = robust_cinv(pwadyn, goal); 
set_chain = bw_chain(pwadyn, cinv, S1);
% simulate_3d(pwddyn, chain);

%% Plot stuff
figure(1)
clf
hold on
plot(intersect1(Polyhedron([ 0 1 0], [200]), cinv), 'alpha', 0.3, 'color', 'green')
xlabel('$v$')
ylabel('$h$'); ylim([-5 200])
zlabel('$v_L$')

matlab2tikz('invariant_set.tikz','interpretTickLabelsAsTex',true, 'width','\figurewidth', 'height', '\figureheight', 'parseStrings',false, 'showInfo', false)