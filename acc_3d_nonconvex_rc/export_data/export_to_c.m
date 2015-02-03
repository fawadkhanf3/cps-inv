% define polyhedron we want to steer to
Hx = [1 0; -1 0; 0 1; 0 -1];
hx = [1; 1; 1; 1];

% define dynamics x(t+1) = Ax(t) + Bu(t) + Ed(t) + K
dyn.A = [0.9 0.1; 0.1 0.9];
dyn.B = [0; 1];
dyn.E = zeros(2,0);
dyn.K = [0.2; 0];

% define constraints on input: dyn.XUA = [Hux Huu], dyn.XUb = hu
dyn.XUA = [0 0 1; 0 0 -1];
dyn.XUb = [1; 1];

fileID = fopen('output_file.txt','w');

write_data(Hx, fileID);
write_data(hx, fileID);
write_data(dyn.A, fileID);
write_data(dyn.B, fileID);
write_data(dyn.E, fileID);
write_data(dyn.K, fileID);
write_data(dyn.XUA, fileID);
write_data(dyn.XUb, fileID);

fclose(fileID);