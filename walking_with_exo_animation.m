function walking_with_exo_animation(lt, s, rt, rs)
%% prepare knee angle data
theta = 0:1:70;

%% 创建图窗
screenSize = get(0, 'ScreenSize');
width = screenSize(3) / 2.5;
left = screenSize(3) / 4;
bottom = screenSize(4) / 4;
height = screenSize(4) / 2;
fig = figure('Position', [left bottom width height], 'Color','w');
set(fig, 'DoubleBuffer', 'on');
set(gca, 'xlim', [-120,120], 'ylim', [-120 120], 'NextPlot', 'replace', 'Visible', 'off');
% nextFrameTime = 0;
% timescale = 0.1;
FramePerSec = 15;
mov = VideoWriter('walking_animation');
mov.FrameRate = FramePerSec;
mov.Quality = 100;
open(mov);

%% 绘图
% %                               hip
% %                             ↑
% %                          rt |
% %                      A -----| D
% %                             |
% %                             |
% %                             | lt
% %                             |
% %                             |
% %        --------------------------------------------->
% %                            ╱| O
% %                      ls  ╱  |
% %             C ╲        ╱  θ |
% %              rs ╲    ╱      |
% %                   ╲╱        |
% %                    B        |
% %                             |
% %                             |
dt = 0.1;
t = 0:dt:(length(theta)-1)*dt;
for i = 1 : length(t)
    % if t(i)>=nextFrameTime || i==length(t)
    % nextFrameTime = nextFrameTime + timescale / FramePerSec;
    hold off
    % 从theta = 0开始，依次将前一次迭代结果作为本次的初始值

    hipX = 0;
    hipY = 0.4;
    DX = 0;
    DY = lt;
    OX = 0;
    OY = 0;
    AX = -rt;
    AY = lt;
    BX = -sind(theta(i)) * 0.3;
    BY = -cosd(theta(i)) * 0.3;
    CX = BX - cosd(theta(i)) * rs;
    CY = BY + sind(theta(i)) * rs;

    plot([OX, hipX], [OY, hipY], 'Color', [0.4 0.4 0.4]);  hold on % thigh
    plot([OX, DX], [OY, DY], 'k'); % thigh part of exoskeleton
    plot([AX, DX], [AY, DY], 'k'); % thigh strap
    plot([OX, BX], [OY, BY], 'k'); % shank part of exoskeleton
    plot([BX, CX], [BY, CY], 'k'); % shank strap
    xlim([-0.5 0.5]); ylim([-0.5 0.5]);
    axis equal
    drawnow;
    F = getframe(gcf);
    writeVideo(mov, F);
end

end