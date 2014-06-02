function [pu_merged, best] = merge1(pu, method, no_envelope)
	% Merge polytopes in PolyUnion pu by constructing a hyperplane arrangement.
	%
	% Input:
	%
	% (int) objective : what to optimize,
	%				1. maximize number of cells of largest Polyhedron
	%				2. maximize volume of largest Polyhedron in result
	%				3. minimize total number of Polyhedra
	%
	% (bool) no_envelope : run algorithm without considering the envelope. Might be faster for 
	%			   		   Polyhedra with a complex envelope.
	%
	% Output: A PolyUnion object describing
	%
	% (PolyUnion) pu_merged : Object describing the merged cells.
	%  
	% (double) performance : Vector containing the objective values, for instance volumes of the cells.
	% Remark: The two choices interfer, since removing the envelope results in
	% 	      a modified optimization problem. 
	%         To compute the true optimizer, set no_envelope=0,
	% 		

	if nargin < 2
		method = 3;
	end
	if nargin < 3
		no_envelope = 0;
	end

	if isa(pu, 'Polyhedron') || pu.Num <= 1
		pu_merged = pu;
		return;
	end

	ha = HypArr(pu, no_envelope);
	white = ha.white_markings(pu);
	[marks, best] = ha.merge(white, method);
	pu_merged = PolyUnion;
	for i=1:size(marks,1)
		if no_envelope
			pu_merged.add(intersect(pu.envelope(), ha.get_poly(marks(i,:))));
		else
			pu_merged.add(ha.get_poly(marks(i,:)));
		end
	end
end