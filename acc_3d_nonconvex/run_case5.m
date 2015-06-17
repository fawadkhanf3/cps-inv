tau_min = 1;
tau_des = 1.4;
v_des = 27;
delta = 1;

% con = constants_aggressive;
con = constants_benign;
%%%% Create dynamics

dyn = get_dyn1(con);
pwadyn = get_dyn2(con);

%%%% Specify specification sets

%Safe set
VH = pwadyn.domain;

M1 = intersect(VH, Polyhedron('H', [0 1 0 v_des*tau_des]))
G1 = intersect(VH, Polyhedron('H', [tau_des -1 0 0; 1 0 0 v_des]));

M2 = intersect(VH, Polyhedron('H', [0 -1 0 -v_des*tau_des]))
G2 = intersect(VH, Polyhedron('H', [1 0 0 v_des+delta; -1 0 0 -v_des+delta]));

S = Polyhedron('H', [tau_min -1 0 0])

%%%%%%%%%%%%%%%%%%%%%
%%%% ITERATION 0 %%%%
%%%%%%%%%%%%%%%%%%%%%

C1 = M1;
C2 = M2;

ALL = merge_in(C1, C2);

figure(1); clf; hold on

plot(M1, 'alpha', 0.1, 'color', 'green')
plot(M2, 'alpha', 0.1, 'color', 'blue')
plot(G1, 'alpha', 0.5, 'color', 'green')
plot(G2, 'alpha', 0.5, 'color', 'blue')

%%%%%%%%%%%%%%%%%%%%%
%%%% ITERATION 1 %%%%
%%%%%%%%%%%%%%%%%%%%%

% for C1
disp('Iteration 1, cinv set 1')
Inv1_outer = intersect(S, intersect(G1, ALL));
[~, Inv1] = in_out_cinv(dyn, pwadyn, Inv1_outer);

disp('Iteration 1, Reach set 1-inv')
% Can reach Inv1 iff we can reach Inv1(1)
C1_1_all = pre_pwa(pwadyn, Inv1(1), intersect(S, ALL));
C1_1 = intersect(C1_1_all, M1);

disp('Iteration 1, Reach set 1-C2')
C1_2 = pre_pwa(pwadyn, C2, intersect(S, ALL));
C1_2 = intersect(C1_2, M1);

figure(2); clf; hold on
plot(intersect(Inv1, M1), 'color', 'blue', 'alpha', 0.01);
plot(C1_1, 'color', 'red', 'alpha', 0.01);
plot(C1_2, 'color', 'green', 'alpha', 0.01);
% Can verify that Reach(C2) \subset Reach(Inv1)!


C1 = C1_1;

disp('Iteration 1, Inv set 2')
Inv2_outer = intersect(S, intersect(G2, ALL));
[~, Inv2] = in_out_cinv(dyn, pwadyn, Inv2_outer);
% Invariant set is empty here

disp('Iteration 1, Reach set 2-C1')
C2_2 = pre_pwa(pwadyn, C1(16), intersect(S, ALL), 0, 6);
C2_2 = intersect(C2_2, M2)
C2 = C2_2;

figure(3); clf; hold on
plot(C1, 'color', 'blue', 'alpha', 0.01)
plot(intersect(C2, Polyhedron('H', [0 1 0 200])), 'color', 'red', 'alpha', 0.01)

%%%%%%%%%%%%%%%%%%%%%
%%%% ITERATION 2 %%%%
%%%%%%%%%%%%%%%%%%%%%

% Since we disregarded from where C2 could be reached, we have that
%  C1 \subset M1 \cap Reach( Inv ( G1 \cap (C1 \cup C2) \cup C2 ) )
%
% same holds for C2 -> convergence

figure(4); clf; hold on
plot(C1, 'color', 'blue', 'alpha', 0.01, 'linestyle', 'none')
plot(intersect(C2, Polyhedron('H', [0 1 0 200])), 'color', 'blue', 'alpha', 0.03, 'linestyle', 'none')
plot(intersect(G2, Polyhedron('H', [0 1 0 200])), 'color', 'red', 'alpha', 0.1)
% plot(intersect(Inv1, Polyhedron('H', [0 1 0 200])), 'color', 'green', 'alpha', 0.01)

fig_h = open('dom_points.fig');
ax_h = get(fig_h, 'CurrentAxes');
ch_h = get(ax_h, 'children');
xdata = get(ch_h, 'xdata')
ydata = get(ch_h, 'ydata')
zdata = get(ch_h, 'zdata')

xdata = reshape(xdata, 1, 3*length(xdata));
ydata = reshape(ydata, 1, 3*length(ydata));
zdata = reshape(zdata, 1, 3*length(zdata));

un = unique([xdata' ydata', zdata'], 'rows')

figure(4)
plot3(un(:,1), un(:,2), un(:,3), 'kx')