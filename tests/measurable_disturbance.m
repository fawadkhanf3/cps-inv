dmax = 0.5;
dmmax = 0.3;
umax = 1;

C = Polyhedron('V', 10*[0.3 0.3; 1 0; 0 1]);

A = eye(2);
K = zeros(2,1);
B = eye(2);
XU_set = Polyhedron('H', [0 0 1 0 umax; 0 0 -1 0 umax; 0 0 0 1 umax; 0 0 0 -1 umax]);

dyn = Dyn(A,K,B,XU_set, [1 0 1 0; 0 1 0 1], [0 0 dmmax; 0 0 dmmax; 0 0 dmax; 0 0 dmax], [0 0 -dmmax; 0 0 -dmmax; 0 0 -dmax; 0 0 -dmax])
dynm = Dyn(A,K,B,XU_set, eye(2), [0 0 dmax; 0 0 dmax], [0 0 -dmax; 0 0 -dmax], eye(2), Polyhedron('H', [1 0 dmmax; -1 0 dmmax; 0 1 dmmax; 0 -1 dmmax;]));

preC = dyn.pre(C);
preCm = dynm.pre(C);

clf
hold on
plot(C, 'color', 'black', 'alpha', 1)
plot(preCm, 'color', 'blue', 'alpha', 0.5)
plot(preC, 'color', 'green', 'alpha', 0.5)