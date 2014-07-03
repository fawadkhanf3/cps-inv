classdef Dyn
    
    % DYN: Create a Dyn object.
    % ========================================
    %
    % SYNTAX
    % ------
    %
    %   dyn = Dyn(A,K,B,XU_set,E)
    %   dyn = Dyn(A,K,B,XU_set,E,XD_plus,XD_minus)
    %   dyn = Dyn(A,K,B,XU_set,E,XD_plus,XD_minus,Em,Dm_set)
    % 
    % DESCRIPTION
    % ------    
    %   An instance of this class represents a discrete-time
    %   linear system of the form
    %   x(t+1) = Ax(t) + Bu(t) + Ed(t) + Em dm(t) + K
    % 
    %   A is n x n
    %   B is n x m
    %   E is n x p
    %   K is n x 1
    %
    %   u(t) is the control input
    %   d(t) is a non-measurable disturbance
    %   dm(t) is a measurable disturbance
    %
    %   - Input constraint:                             [x; u] \in XU_set, a n+m-dimensional Polytope
    %   - (State-dependent) disturbance constraints:    d \leq XD_plus*[ x; 1 ],  XD_plus is p x (d+1)
    %                                                   d \geq XD_minus*[ x; 1 ]  XD_minus is p x (d+1)
    %   - Measurable disturbance constraint:            dm \in Dm_set
    %

    properties (SetAccess=protected)
        A;          % n x n array
        B;          % n x m array
        E;          % n x p array
        Em;         % n x pm array
        K;          % n x 1 array
        XU_set;     % Polyhedron
        XD_plus;    % p x n+p array
        XD_minus;   % p x n+p array
        Dm_set;
        n;
        m;
        p;
        pm;
        constants;  % Map of additional constants associated with the object (key-value pairs)
    end
    
    methods
        % Constructor
        function d = Dyn(A,K,B,XU_set,E,XD_plus,XD_minus,Em,Dm_set)
            d.n = size(A,2);

            if size(A) ~= [d.n d.n]
                error('Wrong dimensions in dynamics definition')
            end

            if nargin<8
                % No measurable disturbance
                Em = zeros(d.n,0);
                Dm_set = Polyhedron('H', zeros(0,d.n));
            end

            if nargin<5
                % No disturbance
                E = zeros(d.n,0);
                XD_plus = zeros(0,d.n);
                XD_minus = zeros(0,d.n);
            end

            d.m = size(B,2);
            d.p = size(E,2);
            d.pm = size(Em,2);
            if [size(B,1) size(E,1) size(Em,1) size(K,1)] ~= [d.n d.n d.n d.n]
                error('Wrong dimensions in dynamics definition')
            end

            d.A = A;
            d.B = B;
            d.E = E;
            d.Em = Em;
            d.K = K;
            d.XU_set = XU_set;
            d.XD_plus = XD_plus;
            d.XD_minus = XD_minus;
            d.Dm_set = Dm_set;
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

