clear all;
load set_mat

%%%%%%%%%%%%%%%% Plot inner cinv set %%%%%%%%%%%%%%%%
figure(1); clf;  hold on;

poly200 = Polyhedron('H', [0 1 0 200]);
plot(intersect1(goal, poly200), 'color', 'blue', 'alpha', 0.1)

plot(intersect1(set_mat{1}(1), poly200), 'color', 'green', 'alpha', 0.3)
xlabel('$v$')
ylabel('$h$')
zlabel('$v_L$')
text(1, 100, 15, '$C_0$')
text(20, 10, 5, '$G_2$')
view([-28 4])

matlab2tikz('C0.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)

%%%%%%%%%%%%%%%% Plot full cinv set %%%%%%%%%%%%%%%%
figure(2); clf; hold on

plot(intersect1(S1, poly200), 'color', 'red', 'alpha', 0.1)
plot(intersect1(goal, poly200), 'color', 'blue', 'alpha', 0.2)

for i=1:2:length(set_mat{1})
	plot(intersect1(set_mat{1}(i), poly200), 'color', 'green', 'alpha', 0.1)
end
for j = 1:4:length(set_mat{end})
	plot(intersect1(set_mat{end}(j), poly200), 'color', 'green', 'alpha', 0.06, 'linestyle', 'none')
end

xlabel('$v$')
ylabel('$h$')
zlabel('$v_L$')
view([-28 4])
text(1, 100, 15, '$C_1$')
text(20, 10, 5, '$G_2$')
text(28, 10, 5, '$S_2$')
text(24, 10, 30, '$S_2 \cap Pre(C_1)$')

matlab2tikz('3d_domain.tikz','interpretTickLabelsAsTex',true, ...
		     'width','\figurewidth', 'height', '\figureheight', ...
		     'parseStrings',false, 'showInfo', false)