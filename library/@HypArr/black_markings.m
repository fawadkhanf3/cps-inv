function markings = black_markings(ha, white_markings)
	% Return all the markings inside env, but remove those 
	% corresponing to polytopes from which ha was made
	env = envelope_marking(white_markings);
	markings = enumerate(ha, env);
	markings(ismember(markings, white_markings, 'rows'),:) = [];
end

function env_mark = envelope_marking(marking)
	% Get the marking of the envelope of `markings'
	[N_m, N_hp] = size(marking);
	env_mark = fix(sum(marking, 1)/N_m);
end