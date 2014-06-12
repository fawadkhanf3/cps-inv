function [pu_merged, best] = merge1(pu, method, no_envelope)
    % MERGE1: Merge polytopes in PolyUnion pu by constructing a hyperplane arrangement.
    % ======================================================
    %
    % SYNTAX
    % ------
    %   [merged, best] = merge1(pu)
    %   [merged, best] = merge1(pu, method, no_envelope)
    %
    % DESCRIPTION
    % -----------
	% 	Given a (non-convex) PolyUnion, tries to find 
	% 	a different representation of the same set such
	% 	that a given criterion is maximized.
    % 
    % INPUT
    % -----
    %   pu     	Set to merge
    %           Class: PolyUnion
    %   method 	Objective to maximize (int):
    %    			1: maximize number of cells of largest Polyhedron
	%				2: maximize volume of largest Polyhedron in result
	%				3: minimize total number of Polyhedra
    %          	Default: 3
    %	no_envelope	Run algorithm without considering the envelope. Might be faster for 
	%			    Polyhedra with a complex envelope.
	%  				Default: false
	%
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