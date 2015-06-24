%% extract_intervals: extract intervals of 1's from binary sequence
function [ivals] = extract_intervals(seq)

	differ = seq(2:end) - seq(1:end-1);
	ch_plus = 1+find(differ == 1);
	ch_minus = find(differ == -1);
	if seq(1) == 1
		ch_plus = [1 ch_plus];
	end
	if seq(end) == 1
		ch_minus = [ch_minus length(seq)];
	end

	ivals = [ch_plus' ch_minus'];