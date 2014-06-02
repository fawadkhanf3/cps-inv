classdef Dyn
    
    %
    % Class for discrete-time linear dynamics
    % 
    % x(t+1) = Ax(t) + Bu(t) + Ed(t) + K
    % 
    % Input constraint:         [x; u] \in XD_poly, a n+m-dimensional Polytope
    % Disturbance constraints   d \leq XD_plus*[ x; ones(p,1) ]
    %     (state-dependent)     d \geq XD_minus*[ x; ones(p,1) ]
    %

    properties (SetAccess=protected)
        A;          % n x n array
        B;          % n x m array
        E;          % n x p array
        K;          % n x 1 array
        XU_set;     % Polyhedron
        XD_plus;    % p x n+p array
        XD_minus;   % p x n+p array
        n;
        m;
        p;
        constants;  % Map of additional constants associated with the object (key-value pairs)
    end
    
    methods
        % Constructor
        function d = Dyn(A,B,K,E,XU_set,XD_plus,XD_minus)
            d.n = size(A,2);
            d.m = size(B,2);
            d.p = size(E,2);
            if [size(B,1) size(E,1) size(K,1)] ~= [d.n d.n d.n]
                error('Wrong dimensions in dynamics definition')
            end
            if ~isa(XU_set, 'Polyhedron')
                error('5th argument must be a Polyhedron')
            end
            if nargin<6
                XD_plus = zeros(1,d.n);
                XD_minus = zeros(1,d.n);
            end

            d.A = A;
            d.B = B;
            d.E = E;
            d.K = K;
            d.XU_set = XU_set;
            d.XD_plus = XD_plus;
            d.XD_minus = XD_minus;
            d.constants = containers.Map;
        end
        function [poly] = xd_poly(dyn)
            nP = size(dyn.XD_plus,1);
            nM = size(dyn.XD_minus,1);

            XD_plus_x = dyn.XD_plus(:,1:dyn.n);
            XD_plus_c = dyn.XD_plus(:,dyn.n+1);
            XD_minus_x = dyn.XD_minus(:,1:dyn.n);
            XD_minus_c = dyn.XD_minus(:,dyn.n+1);
            poly = Polyhedron([-XD_plus_x ones(nP,1); XD_minus_x -ones(nM,1)], [XD_plus_c; -XD_minus_c]);
        end
        function x1 = apply(dyn,x0,u,d)
            % Apply input u and disturbance d to state x0.
            if nargin<4
                d = zeros(dyn.p,1);
            end
            x1 = dyn.A*x0 + dyn.B*u + dyn.K + dyn.E*d;
        end
        function x1 = apply_real(dyn,x0,u,d)
            % Apply input u and disturbance d to state x0. Scale with condition numbers
            u_real = u*dyn.get_constant('B_cond_number');
            if nargin<4
                d_real = zeros(dyn.p,1);
            else
                d_real = d*dyn.get_constant('E_cond_number');
            end
            x1 = dyn.A*x0 + dyn.B*u_real + dyn.K + dyn.E*d_real;
        end
        function save_constant(dyn, key, value)
            dyn.constants(key) = value;
        end
        function value = get_constant(dyn, key)
            value = dyn.constants(key);
        end
    end
end

