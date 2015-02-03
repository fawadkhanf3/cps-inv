for i=1:pwadyn.num_region

	fileID = fopen(strcat(['dynamics_', num2str(i), '.txt']),'w');

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

	fclose(fileID);

end



for i=1:length(set_mat)

	fileID = fopen(strcat(['sets_', num2str(i), '.txt']),'w');

	for j=1:length(set_mat{i})
		write_data(set_mat{i}(j).A, fileID);
		write_data(set_mat{i}(j).b, fileID);
	end

	fclose(fileID);
end



