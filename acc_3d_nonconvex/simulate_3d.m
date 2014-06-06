function [t_vec, x_vec, u_vec] = simulate_3d(C_rcinv)

	dT = 0.5;
	x0 = [70/3.6 1.4*70/3.6 70/3.6]';

	pwd = get_pw_dyn(dT,70/3.6);

	x = x0;
	t_vec = 0:dT:100;
	x_vec = zeros(3,length(t_vec));
	u_vec = zeros(1,length(t_vec));

	disp('Starting simulation')
	for i=1:length(t_vec)	
		t = t_vec(i);
		x_vec(:,i) = x;

		if ~C_rcinv.contains(x)
			disp('Fell out of set!')
		end

		% next_poly_nr = get_poly(C_vec, x);
		% next_poly = C_vec{next_poly_nr};
		this_dyn = pwd.get_region_dyn(x);

		v_now = x_vec(1,i);
		v_lead_now = x_vec(3,i);
		v_lead_prev = x_vec(3,max(1,i-1));
		v_des = v_now + (v_lead_now-v_lead_prev);
		h_des = 1.4*v_now;
		h_des_weight = 2;
		v_des_weight = 1;
		Rx = [ v_des_weight 0 0; 0 h_des_weight 0; 0 0 0 ];
		rx = [ -v_des_weight*v_des ;-h_des_weight*h_des; 0 ];

		u_des = u_vec(max(1,i-1));
		u_des_weight = 0;
		Ru = u_des_weight;
		ru = -u_des*u_des_weight;

		u = this_dyn.solve_mpc(x, 0, C_rcinv, Rx, rx, Ru, ru, 1);
		d = get_disturbance(t, x, this_dyn);
		u_vec(i) = u;

		x_next = this_dyn.A*x + this_dyn.B*u + this_dyn.E*d + this_dyn.K;
		x = x_next;
	end

	figure(1); clf; hold on;
	[ax,h1,h2] = plotyy(t_vec, x_vec([1 3],:), t_vec,  x_vec(2,:)./x_vec(1,:));
	set(get(ax(1),'Ylabel'),'String','Speed [m/s]') 
	set(get(ax(2),'Ylabel'),'String','Time headway [s]') 
	xlabel('Time [s]')
	legend('tracking car', 'lead car')

	figure(2); clf; hold on;
	plot(C_rcinv,'alpha',0.1, 'color', 'blue');
	plot3(x_vec(1,:),x_vec(2,:),x_vec(3,:),'r');
	xlabel('following'), ylabel('headway'), zlabel('lead')
end


function num = get_poly(C_vec, x)
	% return which polytope to go to
	num = length(C_vec);
	for i=1:length(C_vec)
		if C_vec{i}.contains(x)
			num = 1+mod(i-1,length(C_vec));
			return;
		end
	end
	disp('not inside cell');
end

function a = get_disturbance(t, x, dyn)
	dmin = dyn.XD_minus*[x; 1]+0.5;
	dmax = dyn.XD_plus*[x; 1]-0.1;
	a = (t<30)*dmax + (t>30)*(t<60)*dmin + (t>70)*dmax*0.5;
	return;
end