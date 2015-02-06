con = constants;
dyn = get_4d_dyn(con);

ymax = 0.9; %half lane width
rmax = con.a*con.u0*con.F_yfmax/(con.b^2*con.Car);

domain = Polyhedron('A', [eye(4); -eye(4)], ...
					'b', [2*ymax; 1; 0.15; 1*rmax; 2*ymax; 1; 0.15; 1*rmax]);

safe = Polyhedron('A', [1  0 0 0;
						-1 0 0 0], ...
				  'b', [ymax;
				  	    ymax] ...
				  );

K = intersect1(safe,domain);

% create poly in x-u space
K_x = K.projection([1 2 3]);
K_d = K.projection([4]);

figure(1); clf; hold on
plot(K_x, 'color', 'green', 'alpha', 0.2)

figure(2); clf; hold on
plot(K_d, 'color', 'green', 'alpha', 0.9)

U = dyn.XU_set.projection([5]);
U.normalize
U = Polyhedron('H', [1 1; -1 1]);

%% Iteration 1

% Find controlled-invariant x

XU_set_red = Polyhedron('H', [zeros(size(U.H,1), 3) U.H]);

red_dyn1 = Dyn(dyn.A(1:3, 1:3), dyn.K(1:3), dyn.B(1:3), XU_set_red, dyn.A(1:3, 4), [zeros(1,3) K_d.b(1)], [zeros(1,3) -K_d.b(2)] );

C_x1 = red_dyn1.cinv_oi(K_x);

% See if d const respected

XU_d_A = [C_x1.A 			      zeros(size(C_x1.A,1), 1); 
		  zeros(size(U.A, 1), 3)  U.A ];

XU_d_b = [C_x1.b; 
		  U.b];

XU_d = Polyhedron('A', [zeros(size(XU_d_A,1), 1) XU_d_A], 'b', XU_d_b);
d_dyn = Dyn(dyn.A(4,4), dyn.K(4), [dyn.A(4, 1:3) dyn.B(4)], XU_d);

origin = Polyhedron('H', [1 0.01; -1 0.01]);

D_set1 = origin;
plot(D_set1);
xlim([-3 3])

for i=1:5
	D_set1 = d_dyn.post(D_set1);
	D_set1.normalize;
end

figure(1);
plot(C_x1, 'color', 'red', 'alpha', 0.2)

figure(2);
plot(D_set1, 'color', 'red', 'alpha', 0.2)

isEmptySet(mldivide(K_d, D_set1));

%% Iteration 2

% Find controlled-invariant x

red_dyn2 = Dyn(red_dyn1.A, red_dyn1.K, red_dyn1.B, red_dyn1.XU_set, red_dyn1.E, [zeros(1,3) D_set1.b(1)], [zeros(1,3) -D_set1.b(2)] );

C_x2 = red_dyn2.cinv_oi(K_x);

% See if d const respected

XU_d_A = [C_x2.A 			      zeros(size(C_x2.A,1), 1); 
		  zeros(size(U.A, 1), 3)  U.A ];

XU_d_b = [C_x2.b; 
		  U.b];

XU_d = Polyhedron('A', [zeros(size(XU_d_A,1), 1) XU_d_A], 'b', XU_d_b);
d_dyn = Dyn(d_dyn.A, d_dyn.K, d_dyn.B, XU_d);

origin = Polyhedron('H', [1 0.01; -1 0.01]);

D_set2 = origin;
plot(D_set2);
xlim([-3 3])

for i=1:5
	D_set2 = d_dyn.post(D_set2);
	D_set2.normalize;
end


figure(1);
plot(C_x2, 'color', 'red', 'alpha', 0.2)

figure(2);
plot(D_set2, 'color', 'red', 'alpha', 0.2)
