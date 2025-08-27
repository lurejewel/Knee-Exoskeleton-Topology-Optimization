function fit = KCF_analysis(exoConfig, model, tempData, OptReporter)
% import org.opensim.modeling.*

% mechanical params
lt = exoConfig(1)/1;  s = exoConfig(2)/1;
rt = exoConfig(3)/1;  rs = exoConfig(4)/1;
% control params
plataeuStartTime = exoConfig(5);
plataeuEndTime = exoConfig(6);
assistEndTime = exoConfig(7);

[exo_force, theta] = cal_force_and_knee_angle(plataeuStartTime, plataeuEndTime, assistEndTime);

w1 = 0.8; w2 = 0.1; w3 = w2; % weighting parameters of the cost function (fit)
GN = 70*9.8; rtN = 0.5/2/pi; rsN = 0.35/2/pi; % normalizing constant of jraPeakHS, rt and rs: the body weight, and the radii of human thigh and shank.

l0 = 0.09;
% if l0 + 2*s - lt < 0.01

% calculate axial and radial components of the exoskeleton force along the thigh and the shank seperately
lc = l0+2*s-lt;
if lc<0.04 || lc>0.25 || lc+s>0.3 || s>0.1 || lt <0.1 % cannot reach max knee flex angle
    fprintf(OptReporter, [char(datetime) ': can not reach max knee flex / out of bounds at [lt  s  rt  rs]=[', num2str([lt s rt rs],10), '].\n']);
    jraPeakHS = 9999;
    fit = 9999;
    return;
end
[forceAng_thigh, forceAng_shank, ls, report] = cal_force_angle_and_ls(lt, s, rt, rs, theta);
if report(2)
    fprintf(OptReporter, [char(datetime) ': can not reach max knee flex / out of bounds at [lt  s  rt  rs]=[', num2str([lt s rt rs],10), '].\n']);
    jraPeakHS = 9999;
    fit = 9999;
    return;
end

forceX_thigh = exo_force .* sind(forceAng_thigh);
forceY_thigh = exo_force .* cosd(forceAng_thigh);
forceX_shank = exo_force .* sind(forceAng_shank);
forceY_shank = exo_force .* cosd(forceAng_shank);

% read data of external forces from .mot file
forceData = org.opensim.modeling.Storage('uphill_walking_calibrated_forces_ORIGINAL.mot');
femur_assistance_force_vx = tempData.femur_assistance_force_vx;
femur_assistance_force_vy = tempData.femur_assistance_force_vy;
femur_assistance_force_px = tempData.femur_assistance_force_px;
femur_assistance_force_py = tempData.femur_assistance_force_py;
tibia_assistance_force_vx = tempData.tibia_assistance_force_vx;
tibia_assistance_force_vy = tempData.tibia_assistance_force_vy;
tibia_assistance_force_px = tempData.tibia_assistance_force_px;
tibia_assistance_force_py = tempData.tibia_assistance_force_py;
forceData.getDataColumn(19-1, femur_assistance_force_vx); % -1 cuz the time column is NOT taken into account here
forceData.getDataColumn(20-1, femur_assistance_force_vy);
forceData.getDataColumn(22-1, femur_assistance_force_px);
forceData.getDataColumn(23-1, femur_assistance_force_py);
forceData.getDataColumn(28-1, tibia_assistance_force_vx);
forceData.getDataColumn(29-1, tibia_assistance_force_vy);
forceData.getDataColumn(31-1, tibia_assistance_force_px);
forceData.getDataColumn(32-1, tibia_assistance_force_py);

% modify data of external forces
for i = 0 : forceData.getSize-1
    femur_assistance_force_vx.set(i, forceX_thigh(i+1));  % +X (forward when positive)
    femur_assistance_force_vy.set(i, forceY_thigh(i+1));  % +Y (upward when positive)
    femur_assistance_force_px.set(i, -rt);                % -X (backward when positive)
    femur_assistance_force_py.set(i, -0.396+lt);          % -Y (downward when positive)
    tibia_assistance_force_vx.set(i, forceX_shank(i+1));  % +X
    tibia_assistance_force_vy.set(i, -forceY_shank(i+1)); % -Y
    tibia_assistance_force_px.set(i, -rs);                % -X
    tibia_assistance_force_py.set(i, -ls(i+1));           % -Y
end
forceData.setDataColumn(19-1, femur_assistance_force_vx);
forceData.setDataColumn(20-1, femur_assistance_force_vy);
forceData.setDataColumn(22-1, femur_assistance_force_px);
forceData.setDataColumn(23-1, femur_assistance_force_py);
forceData.setDataColumn(28-1, tibia_assistance_force_vx);
forceData.setDataColumn(29-1, tibia_assistance_force_vy);
forceData.setDataColumn(31-1, tibia_assistance_force_px);
forceData.setDataColumn(32-1, tibia_assistance_force_py);

% print data of external forces to .mot file
forceData.print('uphill_walking_calibrated_forces.mot');

%% execute inverse dynamics analysis
idTool = org.opensim.modeling.InverseDynamicsTool('Setup_ID.xml'); % configure ID Tool
idTool.setModel(model);
idTool.run();

%% execute static optimization analysis
soTool = org.opensim.modeling.AnalyzeTool('Setup_SO.xml');
soTool.run();

%% execute joint reaction analysis

jraTool = org.opensim.modeling.AnalyzeTool('Setup_JRA.xml');
jraTool.run();

%% read & store jra calculations
jraData = org.opensim.modeling.Storage('Joint Reaction Analysis\model_scaled_JointReaction_ReactionLoads.sto');
jraX = tempData.jraX;
jraY = tempData.jraY;
jraZ = tempData.jraZ;
jraData.getDataColumn(0, jraX);
jraData.getDataColumn(1, jraY);
jraData.getDataColumn(2, jraZ);
jraCurve = nan(1, jraData.getSize);
for i = 0 : jraData.getSize-1
    jraCurve(i+1) = sqrt(jraX.get(i)^2 + jraY.get(i)^2 + jraZ.get(i)^2);
end
temp = norm_gait_cycle(jraCurve);
jraPeakHS = max(temp(1:250));

fit = w1 * jraPeakHS/GN + w2 * rt/rtN + w3 * rs/rsN;
fprintf(OptReporter, [char(datetime) ': finished at [lt  s  rt  rs]=[', num2str([lt s rt rs],10), ']. jraPeakHS = ', num2str(jraPeakHS,4), ' N. fit = ', num2str(fit,4), '.\n']);

end