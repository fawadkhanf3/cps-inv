for i=1:length(set_mat)

	fileID = fopen(strcat(['sets_', num2str(i), '.txt']),'w');

	for j=1:length(set_mat{i})
		write_data(set_mat{i}(j).A, fileID);
		write_data(set_mat{i}(j).b, fileID);
	end

	fclose(fileID);
end



