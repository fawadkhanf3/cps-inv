show_plot=1;

if show_plot
	clf; hold on;
end

% read constants
con = constants_rc;

% get dynamics model
dyn_model = get_2d_dyn(con);

%% define V-H State space
VH = Polyhedron([1 0; -eye(2)], [con.v_max; -con.v_min; -con.d_min]);

%% Define safe set
S1 = intersect1(VH, Polyhedron('A', [con.tau_min -1; 0 -1], 'b', [0; -con.h_min]));

%% Define goal set
G2 = intersect1(VH, Polyhedron('A', [con.tau_des  -1; 1 0], 'b', [0; con.v_des]));

%% Use inside-out approach starting with V0
C0 = intersect1(G2, Polyhedron([1 0; -1 0], [con.v_lead; -con.v_lead])); 
% C1 = dyn_model.cinv_io(G2, C0, show_plot);

%% Use outside-in
C1 = dyn_model.cinv_oi(G2, show_plot);

%% Build chain of sets
control_chain = [C1];
while true
	preset = intersect1(S1, dyn_model.pre(control_chain(end) ));
	if isEmptySet(mldivide(preset, control_chain(end)))
		break;
	end
	if show_plot
		plot(preset, 'color', 'blue', 'alpha', 0.1);
		drawnow;
	end
	control_chain = [control_chain preset];
end

save('simulation/control_chain.mat', 'control_chain')

if true
	A = dyn_model.A;
	B = dyn_model.B;
	E = dyn_model.E;
	K = dyn_model.K;
	XUA = dyn_model.XU_set.A;
	XUb = dyn_model.XU_set.b;
	n = dyn_model.n;
	m = dyn_model.m;
	p = dyn_model.p;
	save('codegen/dyn_data.mat', 'A', 'B', 'E', 'K', 'XUA', 'XUb', 'n', 'm', 'p');

	save('codegen/constants.mat', 'con')

	polyA = control_chain(1).A;
	polyb = control_chain(1).b;
	save('codegen/poly.mat', 'polyA', 'polyb');

end