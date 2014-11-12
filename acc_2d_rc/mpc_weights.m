function  [Rx,rx,Ru,ru] = mpc_weights(v,h,N,con)

  % change these
  con_v_weight = 1;
  con_h_weight = 5;
  con_u_weight = 100;
  con_u_weight_jerk = 10;
  con_ramp_lim = 0.3;   % 
  con_ramp_delta = 0.6;


  v_goal = min(con.v_des, con.v_lead);
  h_goal = max(con.h_safe, con.tau_des*v);

  lim = con_ramp_lim;
  delta = con_ramp_delta;
  ramp = max(0, min(1, 0.5+abs(v-con.v_lead)/delta-lim/delta));

  v_weight      = con_v_weight;
  h_weight      = con_h_weight*(1-ramp);
  u_weight      = con_u_weight;
  u_weight_jerk = con_u_weight_jerk;

  Rx = kron(eye(N), [v_weight 0; 0 h_weight]);
  rx = repmat([v_weight*(-v_goal); h_weight*(-h_goal)],N,1);

  Ru = u_weight*eye(N);
  if N>2
    Ru = Ru + u_weight_jerk*(diag([1 2*ones(1,N-2) 1]) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
  else
    Ru = Ru + u_weight_jerk*(diag(ones(1,N)) - diag(ones(N-1,1), -1) - diag(ones(N-1,1), 1));
  end
  ru = zeros(N,1);

end