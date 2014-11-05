con = constants;
dyn = get_4d_dyn(con);

ymax = 1;
vmax = 1;
psimax = 0.1;
rmax = 0.4;

ymin = -1;
vmin = -1;
psimin = -0.1;
rmin = -0.4;

% A is stable

[P J] = jordan(dyn.A);    % A = P*J*inv(P)

% Maximize in polytope

domain = Polyhedron('A', [eye(4); -eye(4)], 'b', [ymax; vmax; psimax; rmax; -ymin; -vmin; -psimin; -rmin]);

xu_poly = Polyhedron('A', [domain.A zeros(size(domain.A,1),1); dyn.XU_set.A], 'b', [domain.b; dyn.XU_set.b]);

solmax = xu_poly.extreme([0 0 0 0 1]);
solmin = xu_poly.extreme([0 0 0 0 -1]);

umax = zeros(1,4);
umin = zeros(1,4);

for i=1:4
	vec = zeros(1,4);
	vec(i) = 1;
	maxdir = [ zeros(1,4) real(vec*inv(P)*dyn.B) ];
	mindir = [ zeros(1,4) real(-vec*inv(P)*dyn.B) ];
	solmax = xu_poly.extreme(maxdir);
	solmin = xu_poly.extreme(mindir);
	umax(i) = solmax.supp;
	umin(i) = -solmax.supp;
end

dleft = P(4,:)*diag(1./(1-diag(J)));

dright_plus = umax.*(dleft>0) + umin.*(dleft<0);
dright_minus = umax.*(dleft<0) + umin.*(dleft>0);
dmax = real(dleft*dright_plus')
dmin = real(dleft*dright_minus')