function ret = plotData3(ya1, label_a1, yd1, label_b1, ...
                         ta, td)
%> To plot data in AMBER format
%> ya       : actual outputs data
%> label_a  : desired outputs data
%> yd       : desired outputs
%> label_b  : name for actual outputs data
%> time     : real time on x-axis
%
%%% CopyRight : AMBER Lab
%%% Authors   : Wen-Loong Ma



%%
FS         = 25;   % Font Size for legend
legendSize = 80; % useless shit

scaleSize = 40;  % Size for the scale

labelSize = 40;  % size for all x and y labels

mark_size = 8;

topoffst = 0.74; % Top offset
botoffst = 0.88; % Bottom offset

finalLegendHeight = 0.08;

xaxis    = 'Time(s)';
yaxis    = '$\tau$';

%%
h         = figure;
set(h, 'position', [100 100 1*500 1*400]);

hk(1) = plot(ta, ya1, 'r');
xlim( [ta(1) max(ta)] );
ylim( [0 5 ] ); hold on;  %min( alldata )-2, max( alldata )*1.05
hk(2) = plot(td, yd1, 'b');   hold on; set(hk(2), 'Color', [0,0,0]);
hk(3) = plot(ta, ones(size(ta)), 'g');   hold on; set(hk(3), 'Color', [0,0,0]);


set(hk(:), 'MarkerSize', mark_size, 'LineWidth', 2);
set(hk(1), 'LineStyle', '-');
set(hk(2), 'LineStyle', '--');
set(hk(3), 'LineStyle', '--');

xlabel(xaxis, 'Interpreter', 'LaTex', 'FontSize', labelSize);
ylabel(yaxis, 'Interpreter', 'LaTex', 'FontSize', labelSize);
set(gca,'FontSize', scaleSize, ...
        'position', [0.14   0.28   0.775   0.69]);


% %% 1
% ah1 = gca;
% l = legend(ah1, hk(1), label_a1, 'Location', 'SouthOutside', ...
%            'Orientation', 'Horizontal', 'Box', 'off', ...
%            'FontSize', legendSize, 'Interpreter','LaTeX');
% p = get(l,'position');
% set(l, 'position', [0.03 p(2)-topoffst 0.35 p(4)+.035],  'Box','off');
% l_child1 = get(l,'Children');
% for i = 1:length(l_child1)
%     if strcmp( get(l_child1(i),'Type'),'text')
%         set(l_child1(i),'FontSize', FS, 'Interpreter','LaTeX')
%     end
% end



% %% 2
% ah2 = axes('position',get(gca,'position'), 'visible','off');
% l = legend(ah2, hk(2), label_b1, 'Location','SouthOutside',...
%            'Orientation','Horizontal','Box','off',...
%            'FontSize', legendSize, 'Interpreter', 'LaTeX');
% p = get(l,'position');
% set(l, 'position', [0.4 finalLegendHeight 0.35 p(4)], 'Box','off');
% l_child1 = get(l,'Children');
% for i = 1:length(l_child1)
%     if strcmp( get(l_child1(i),'Type'),'text')
%         set(l_child1(i),'FontSize',FS,'Interpreter','LaTeX')
%     end
% end



% %% 3
% ah2 = axes('position',get(gca,'position'), 'visible','off');
% l = legend(ah2, hk(3), '$\tau^{d}$', 'Location','SouthOutside',...
%            'Orientation','Horizontal','Box','off',...
%            'FontSize', legendSize, 'Interpreter', 'LaTeX');
% p = get(l,'position');
% set(l, 'position', [0.66 finalLegendHeight 0.35 p(4)], 'Box','off');
% l_child1 = get(l,'Children');
% for i = 1:length(l_child1)
%     if strcmp( get(l_child1(i),'Type'),'text')
%         set(l_child1(i),'FontSize',FS,'Interpreter','LaTeX')
%     end
% end

%%
ret = h;
end