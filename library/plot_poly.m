function plot_polytopes(polyvec, colors, alpha)
	h = ishold;
	hold on
	numpoly = length(polyvec);
	% colors=prism(length(polyvec));
	if nargin<2
		colors = eye(3);
	end
	if nargin<3
		alpha = 1;
	end
	for i=numpoly:-1:1
		if nargin<2
			color = ((numpoly-0.8*i)/numpoly)*colors(1+mod(i-1,3),:);
		else
			color = colors(i,:);
		end
		handle = plot(polyvec(i), 'color', color, 'linestyle', 'none', 'alpha', alpha);
		
		% Remove 3d information from components - bad when exporting with matlab2tikz
		for j=1:length(handle)
			v3d = get(handle(j), 'Vertices');
			v2d = v3d(:,1:2);
			set(handle(j), 'Vertices', v2d)
		end
	end
	if ~h
		hold off
	end
end

