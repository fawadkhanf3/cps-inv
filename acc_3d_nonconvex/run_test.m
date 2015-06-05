tau_min = 1;
tau_des = 1.4;
v_des = 25;
delta = 1;

con = constants;

plot_and_video = 1;

%%%% Create dynamics

dyn = get_dyn1(con);
pwadyn = get_dyn2(con);

%%%% Specify specification sets

%Safe set
VH = pwadyn.domain;

M1 = intersect(VH, Polyhedron('H', [0 1 0 v_des*tau_des]))
G1 = intersect(VH, Polyhedron('H', [tau_des -1 0 0; 1 0 0 v_des]));

M2 = intersect(VH, Polyhedron('H', [0 -1 0 -v_des*tau_des]))
% G2 = intersect(VH, Polyhedron('H', [1 0 0 v_des+delta; -1 0 0 -v_des+delta]));
G2 = intersect(VH, Polyhedron('H', [1 0 0 v_des]));

S = Polyhedron('H', [tau_min -1 0 0])

plot(M1, 'color', 'red', 'alpha', 0.2)
plot(M2, 'color', 'green', 'alpha', 0.2)
plot(G1, 'color', 'blue', 'alpha', 0.2)
plot(G2, 'color', 'yellow', 'alpha', 0.2)

% iteration 0

C1 = M1;
C2 = M2;

ALL = merge_in(C1, C2);

figure(1); clf; hold on

plot(M1, 'alpha', 0.1, 'color', 'green')
plot(M2, 'alpha', 0.1, 'color', 'blue')
plot(G1, 'alpha', 0.5, 'color', 'green')
plot(G2, 'alpha', 0.5, 'color', 'blue')

% iteration 1

figure(2); clf; hold on

% for C1
disp('Iteration 1, cinv set 1')
Inv1_outer = intersect(G1, ALL);
[Inv1_inner, Inv1] = in_out_cinv(dyn, pwadyn, Inv1_outer);

disp('Iteration 1, Reach set 1-inv')
% Can reach Inv1 iff we can reach Inv1(1)
C1_1 = pre_pwa(pwadyn, Inv1(end), intersect(S, ALL));
C1_1 = intersect(C1_1, M1);
C1_1p = pre_pwa(pwadyn, Inv1(1), intersect(S, ALL));
C1_1p = intersect(C1_1p, M1);

disp('Iteration 1, Reach set 1-C2')
C1_2 = pre_pwa(pwadyn, C2, intersect(S, ALL));
C1_2 = intersect(C1_2, M1);

plot(intersect(Inv1, M1), 'color', 'blue', 'alpha', 0.05);
plot(C1_1, 'color', 'red', 'alpha', 0.01);
plot(C1_1p, 'color', 'red', 'alpha', 0.01);
plot(C1_2, 'color', 'blue', 'alpha', 0.01);

% Can verify that Reach(C2) \subset Reach(Inv1)!
C1 = C1_1p(end);

disp('Iteration 1, Inv set 2')
Inv2_outer = intersect(G2, ALL)
[~, Inv2] = in_out_cinv(dyn, pwadyn, Inv2_outer);
% this one is empty!

disp('Iteration1, Reach set 2-C1')
C2_2 = pre_pwa(pwadyn, C1, intersect(S, ALL), 5);
