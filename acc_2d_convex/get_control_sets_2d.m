function [control_chain] = get_control_sets_2d(dyn, con, show_plot)

	if nargin<3
		show_plot = 0;
	end

	disp('Loading set controller...')

	v_max = con.v_max;
	v_min = con.v_min;
	d_max = con.d_max;
	d_min = con.d_min;

	h_des = con.h_des;
	h_delta = con.h_delta;

	v_des = con.v_des;
	v_delta = con.v_delta;

	%%%%%%%%%%%%%%%%%%%%%%%%

	%% V-H State space
	VH = Polyhedron([eye(2); -eye(2)], [v_max; d_max; -v_min; -d_min]);

	%% Safe area
	S1 = intersect1(VH, Polyhedron('A', [1 -1], 'b', [0]));

	%%% Desired areas

	G2A = [h_des-h_delta -1;
		   1  			  0];

	G2b = [0; 
		   v_des+v_delta];

	%% Good headway
	G2 = intersect1(VH, Polyhedron('A', G2A, 'b', G2b));

	%% Use outside-in approach
	C1 = dyn.cinv_oi(G2, show_plot, 1e-3);

	%% Use inside-out approach starting with V0
	C0 = intersect1(G2, Polyhedron([1 0; -1 0], [con.v_lead; -con.v_lead])); 
	C1 = dyn.cinv_io(G2, C0, show_plot);

	if show_plot
		pause(1);
	end

	% Find control strategy
	control_chain = dyn.backwards_chain(C1, S1, show_plot, 1e-5);
  	disp('Finished loading the controller.')
end