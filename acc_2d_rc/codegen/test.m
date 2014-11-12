function test(v,h)

load constants
load dyn_data

% v = 30;
% h = 20;

x0 = [v; h];

[H, f, Ai, bi] = qp_vars(x0);

u = quadprog(H,f,Ai,bi);

u = u(1)/u_scale + con.f2*(v-con.v_linearize);
u_mg = u/(con.mass*con.g);
disp('control')
disp(num2str(u))

disp('control/mg')
disp(num2str(u_mg))

end