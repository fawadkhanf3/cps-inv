mixed = {};
for i=1:length(Cinv_upper)
	for j=1:length(Cinv_lower)
		testpoly = intersect(Cinv_lower(j), Cinv_upper(i));
		if ~isEmptySet(testpoly)
			mixed{end+1} = testpoly;
		end
	end
end

% for i=1:length(mixed)
% 	for j=i+1:length(mixed)
% 		disp(['working on i=', num2str(i), ', j=', num2str(j)])
% 		mixed{i} = merge_maxoverlap(mixed{i}, mixed{j});
% 	end
% end

clf; hold on
for k=1:length(mixed)
	plot(mixed{k}, 'color', 'red', 'alpha', 0.1)
end
xlabel('v')
ylabel('h')
zlabel('vL')