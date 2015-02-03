function write_data(object, file)
    fprintf(file, '%d %d\n', size(object,1), size(object,2));
    for j = 1:size(object,1)
            for i = 1:size(object,2)
                fprintf(file, '%f ', object(j,i));
            end
            fprintf(file, '\n');
    end
    fprintf(file, '\n');
end