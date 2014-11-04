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

save('simulation/control_chain.mat', 'control_chain')