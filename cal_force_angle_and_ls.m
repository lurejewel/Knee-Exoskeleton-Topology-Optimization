function [forceAng_thigh, forceAng_shank, lc, report] = cal_force_angle_and_ls(lt, s, rt, rs, theta_)

report = [0 0 0];

%给定穿戴变量与推杆结构参数，单位：m
% lt=0.2;  %大腿锚点沿腿距离
% rt=0.1;  %大腿锚点垂直腿距离
% rs=0.08;  %小腿锚点垂直腿距离
l0=0.09;  %推杆固有长度
L_R=sqrt(rt^2+lt^2); % 大腿锚点到膝关节的直线距离
% s=0.100;   %推杆行程
ls=l0+2*s-lt;   %伸直腿状态下，此时小腿锚点位于直线导轨最上方，小腿锚点沿腿距离

%循环求解实时膝关节角度theta与推杆实时长度L的关系
for i=1:1000
    L(i)=l0+s+(i/1000)*s;  %遍历推杆实时长度
    Lcc=0.150;%表示第一次试探解（关于Lc'）
    Lr(i)=sqrt(Lcc^2+rs^2);
    fx=-Lcc+ls+l0+2*s-L(i);
    while abs(fx)>0.001%直到非常接近原点了，才认为是解，否则一直迭代
        Lcc=Lcc+0.001;%计算x+f(x)
        Lr(i)=sqrt(Lcc^2+rs^2);
        gx=-Lcc+ls+l0+2*s-L(i);%计算f(x+delta)
        Lcc=Lcc-0.001-fx/((gx-fx)/0.001);%牛顿迭代法核心公式，更新Lc'
        Lr(i)=sqrt(Lcc^2+rs^2);
        fx=-Lcc+ls+l0+2*s-L(i);
    end
    LC(i)=Lcc;%大写的LC代表最终求解出的Lc'
    theta_GR(i)=((pi-acos((L(i)^2+L_R^2-Lr(i)^2)/(2*L(i)*L_R)))-acos((rt^2+rs^2+lt^2+Lcc^2-L(i)^2)/sqrt(rt^2+lt^2)/sqrt(rs^2+Lcc^2)/2)-atan(rs/Lcc));
    temp=pi-acos((rt^2+rs^2+lt^2+LC(i)^2-L(i)^2)/sqrt(rt^2+lt^2)/sqrt(rs^2+LC(i)^2)/2)-atan(rt/lt)-atan(rs/LC(i));  %膝关节角度
    if isreal(temp)
        theta(i) = temp;
    else
        theta(i) = nan;
        % report(3) = 1;
        % disp(['part of calculation result of knee angle is not real at [lt  s  rt  rs]=[', num2str([lt s rt rs]), '].']);
    end

    %计算推杆与大小腿的实时夹角
    alpha_L(i)=asin((Lr(i)*sin(acos((rt^2+rs^2+lt^2+LC(i)^2-L(i)^2)/sqrt(rt^2+lt^2)/sqrt(rs^2+LC(i)^2)/2)))/L(i));
    beta_L(i)=asin((L_R*sin(acos((rt^2+rs^2+lt^2+LC(i)^2-L(i)^2)/sqrt(rt^2+lt^2)/sqrt(rs^2+LC(i)^2)/2)))/L(i));
    alpha_R=(pi/2)-atan(rt/lt);
    beta_r(i)=(pi/2)-atan(rs/LC(i));
    theta_h(i)=alpha_L(i) + alpha_R - (pi/2);  %推杆与大腿的夹角
    theta_a(i)=beta_L(i) + beta_r(i) - (pi/2);  %推杆与小腿的夹角
end

% YDKJ = (theta(1) - theta(1000))*180/pi;  %膝关节运动空间，转换为角度制

% plot for debug
% plot(L,rad2deg(theta),'r','LineWidth',1.5, 'DisplayName', '强耦合-双移动副刚柔混联设计');
% xlabel('线性执行器长度/m'); ylabel('膝关节角度/度'); title('行程0.1m时theta与L的关系');
% figure, plot(rad2deg(theta), rad2deg(theta_h)); title('knee angle vs force angle @ thigh');
% figure, plot(rad2deg(theta), rad2deg(theta_a)); title('knee angle vs force angle @ shank');

if ~isreal(sum(theta)) % not necesarry now

    forceAng_thigh = nan;
    forceAng_shank = nan;
    lc = nan;
end

theta_a = theta_a(~isnan(theta));
theta_h = theta_h(~isnan(theta));
LC = LC(~isnan(theta));
theta = theta(~isnan(theta));

if min(theta_) < min(rad2deg(theta))
    report(1) = 1;
end
theta_(theta_<min(rad2deg(theta))) = min(rad2deg(theta));

forceAng_thigh = rad2deg(interp1(theta, theta_h, deg2rad(theta_), 'linear'));
forceAng_shank = rad2deg(interp1(theta, theta_a, deg2rad(theta_), 'linear'));
lc = interp1(theta, LC, deg2rad(theta_), 'linear');

if isnan(sum(forceAng_thigh)) || isnan(sum(forceAng_shank))
    disp(['can not reach maximum knee flexion at [lt  s  rt  rs]=[', num2str([lt s rt rs]), ']. maximum reachable knee flexion angle = ', num2str(rad2deg(max(theta))) ' deg.']);
    report(2) = 1;
end

% end

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
% % |OD| = lt: distance to the knee from where the thigh part of the
% % exoskeleton is attached, along thigh (-Y axis)
% % |AD| = rt: distance to the anatomial axis of the thigh from where the
% % thigh part of the exoskeleton is attached, normal to thigh (-X axis);
% % represents the radius of the thigh
% % |OB| = ls: distance to the knee from where the shak part of the
% % exoskeleton is attached, along shank (Y axis)
% % |BC| = rs: distance to the anatomial ax is of the knee from where the
% % shank part of the exoskeleton is attached, normal to shank (-X axis);
% % represents of radius of the shank
% % θ: the opposite number of knee angle
%
% % lt = 0.2; ls = 0.2;
% % rt = 0.06; rs = 0.09;
% % theta = 30;
%
% O = [0, 0]; % [x y] of knee angle joint
% A = [-rt, lt];
% B = [-ls*sind(theta), -ls*cosd(theta)];
% C = [-ls*sind(theta)-rs*cosd(theta), -ls*cosd(theta)+rs*sind(theta)];
% D = [0, lt];
%
% CA = A-C; OB = B-O; OD = D-O; AC = -CA;
%
% forceAng_thigh = -( atan2d(CA(2), CA(1)) - atan2d(OD(2), OD(1)) );
% forceAng_shank = atan2d(AC(2), AC(1)) - atan2d(OB(2), OB(1));
% le = norm(A-C); % length of the exoskeleton

end