function [C_iter] = robust_cinv_3d

	h_des = 1.4;
	h_delta = 0.2;
	dT = 0.5;

	v_des = 30;
	v_delta = 3;

	% Speed limitaitons for following car [m/s]
	v_f_min = 10/3.6;
	v_f_max = 120/3.6;

	% Distance limitations
	d_max = 200;
	d_min = 0;

	% Speed limitations for lead car [m/s]
	v_l_min = 10/3.6;
	v_l_max = 120/3.6;

	%%%%%%%%%%%%%%%%%%%%%%%%%	

	disp('Looking for a robustly control-invariant set')

	dyn = get_dyn(dT,70/3.6);

	VH = Polyhedron([diag([1 0 1]); -diag([1 0 1])], [v_f_max; d_max; v_l_max; -v_f_min; -d_min; -v_l_min]);

	%Safe set
	S1 = intersect(VH, Polyhedron([1 -1 0], [0]));

	% Goal set
	GA = [h_des-h_delta -1 0;
		   1  			  0 0];
	Gb = [0;
		   v_des+v_delta];
	G = intersect1(VH, Polyhedron('A', GA, 'b', Gb));

	C_iter = G;
	for i=1:60
		i
		C = intersect1(C_iter, pre_removelims(dyn, C_iter, 3, v_l_min, v_l_max))

		plot(C)
		ylim([0 300])
		drawnow
		pause(1)
		C_iter = C;
	end



end

function merged_poly = merge(pu)
	ha = HypArr(pu);
	white = ha.white_markings(pu);
	merged_poly = ha.merge_nr(white);
end