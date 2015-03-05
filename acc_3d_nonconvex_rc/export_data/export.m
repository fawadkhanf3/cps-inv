fileID = fopen('controller/car_constants.txt', 'w');
fprintf(fileID,'%f\n', con.lin_speed);
fprintf(fileID,'%f\n', con.mass);
fprintf(fileID,'%f\n', con.f0);
fprintf(fileID,'%f\n', con.f1);
fprintf(fileID,'%f\n', con.f2);
fprintf(fileID,'%f\n', con.tau_des);
fprintf(fileID,'%f\n', (con.v_des_max + con.v_des_min)/2);
fprintf(fileID,'%f\n', con.f2);
fprintf(fileID,'%f\n', con.h_min);

fclose(fileID);

for i=1:pwadyn.num_region

	fileID = fopen(strcat(['controller/dynamics_', num2str(i), '.txt']),'w');

	write_data(pwadyn.reg_list{i}.A, fileID);
	write_data(pwadyn.reg_list{i}.b, fileID);

	write_data(pwadyn.dyn_list{i}.A, fileID);
	write_data(pwadyn.dyn_list{i}.K, fileID);
	write_data(pwadyn.dyn_list{i}.B, fileID);
	write_data(pwadyn.dyn_list{i}.E, fileID);
	write_data(pwadyn.dyn_list{i}.Em, fileID);

	write_data(pwadyn.dyn_list{i}.XU_set.A, fileID);
	write_data(pwadyn.dyn_list{i}.XU_set.b, fileID);
	write_data(pwadyn.dyn_list{i}.XD_plus, fileID);
	write_data(pwadyn.dyn_list{i}.XD_minus, fileID);

	write_data(pwadyn.dyn_list{i}.get_constant('B_cond_number'), fileID);

	fclose(fileID);

end



for i=1:length(set_mat)

	fileID = fopen(strcat(['controller/sets_', num2str(i), '.txt']),'w');

    fprintf(fileID, '%d\n', length(set_mat));

	for j=1:length(set_mat{i})
		write_data(set_mat{i}(j).A, fileID);
		write_data(set_mat{i}(j).b, fileID);
	end

	fclose(fileID);
end



