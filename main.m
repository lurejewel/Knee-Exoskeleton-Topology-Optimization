clear; close all; clc
import org.opensim.modeling.*

%% load logger and model
% logger
% loggerFile = fopen('opensim.log', 'rt');
% fseek(loggerFile, 0, 'eof'); % move to end of the logger file

% reporter
OptReporter = fopen('Joint Reaction Analysis\optimization report.txt', 'w');

% model
model = Model('scaled_model.osim');
% model.setUseVisualizer(0);
state = model.initSystem();

%% optimization config

optConfig.init = [0.20, 0.09, 0.1, 0.08]'*10000; % initial guess of [lt s rt rs]'
optConfig.lb = [0.05, 0.05, 0.08, 0.06]'*10000; % 
% lower bound
optConfig.ub = [0.25, 0.1, 0.15, 0.15]'*10000; % upper bound
optConfig.tempData = init_opensim_data();
optConfig.options = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt','Display','iter-detailed');

%% prepare data of external forces

[exo_force, theta] = cal_force_and_knee_angle();
jraPeakHS = @(exoConfig) KCF_analysis(exoConfig, model, exo_force, theta, optConfig.tempData, OptReporter);
jraPeakHS_opt = lsqnonlin(jraPeakHS, optConfig.init, optConfig.lb, optConfig.ub, optConfig.options);

fclose(OptReporter);
% rt = 0.1; rs = 0.08; % test
% create exoskeleton force and knee angle vectors that fit .mot file
% ltList = 0.05:0.01:0.30;
% sList = 0.05:0.01:0.10;
% for idxLT = 1 : length(ltList) % lt = ltList
%     lt = ltList(idxLT);
%     for idxS = 1 : length(sList) % s = sList
%         s = sList(idxS);
% 
%         % calculate axial and radial components of the exoskeleton force along the
%         % thigh and the shank seperately
%         [forceAng_thigh, forceAng_shank, ls, report] = cal_force_angle_and_ls(lt, s, rt, rs, theta);
%         if report(2) % cannot reach max knee flex angle
%             jraResults(idxLT, idxS).jraCurve = nan(1, 501);
%             jraResults(idxLT, idxS).report = report;
%             fprintf(OptReporter, [char(datetime) ': can not reach maximum knee flexion at [lt  s  rt  rs]=[', num2str([lt s rt rs]), '].\n']);
%             continue;
%         end
%         forceX_thigh = exo_force .* sind(forceAng_thigh);
%         forceY_thigh = exo_force .* cosd(forceAng_thigh);
%         forceX_shank = exo_force .* sind(forceAng_shank);
%         forceY_shank = exo_force .* cosd(forceAng_shank);
%         if isnan(sum(forceX_thigh)) % not necesarry now
%             error('invalid input parameters.')
%         end
% 
%         % read data of external forces from .mot file
%         forceData = Storage('uphill_walking_calibrated_forces - 副本.mot');
%         femur_assistance_force_vx = ArrayDouble(); % 19
%         femur_assistance_force_vy = ArrayDouble(); % 20
%         femur_assistance_force_px = ArrayDouble(); % 22
%         femur_assistance_force_py = ArrayDouble(); % 23
%         tibia_assistance_force_vx = ArrayDouble(); % 28
%         tibia_assistance_force_vy = ArrayDouble(); % 29
%         tibia_assistance_force_px = ArrayDouble(); % 31
%         tibia_assistance_force_py = ArrayDouble(); % 32
%         forceData.getDataColumn(19-1, femur_assistance_force_vx); % -1 cuz the time column is NOT taken into account here
%         forceData.getDataColumn(20-1, femur_assistance_force_vy);
%         forceData.getDataColumn(22-1, femur_assistance_force_px);
%         forceData.getDataColumn(23-1, femur_assistance_force_py);
%         forceData.getDataColumn(28-1, tibia_assistance_force_vx);
%         forceData.getDataColumn(29-1, tibia_assistance_force_vy);
%         forceData.getDataColumn(31-1, tibia_assistance_force_px);
%         forceData.getDataColumn(32-1, tibia_assistance_force_py);
% 
%         % modify data of external forces
%         for i = 0 : forceData.getSize-1
%             femur_assistance_force_vx.set(i, forceX_thigh(i+1));  % +X (forward when positive)
%             femur_assistance_force_vy.set(i, forceY_thigh(i+1));  % +Y (upward when positive)
%             femur_assistance_force_px.set(i, -rt);                % -X (backward when positive)
%             femur_assistance_force_py.set(i, -0.396+lt);          % -Y (downward when positive)
%             tibia_assistance_force_vx.set(i, forceX_shank(i+1));  % +X
%             tibia_assistance_force_vy.set(i, -forceY_shank(i+1)); % -Y
%             tibia_assistance_force_px.set(i, -rs);                % -X
%             tibia_assistance_force_py.set(i, -ls(i+1));           % -Y
%         end
%         forceData.setDataColumn(19-1, femur_assistance_force_vx);
%         forceData.setDataColumn(20-1, femur_assistance_force_vy);
%         forceData.setDataColumn(22-1, femur_assistance_force_px);
%         forceData.setDataColumn(23-1, femur_assistance_force_py);
%         forceData.setDataColumn(28-1, tibia_assistance_force_vx);
%         forceData.setDataColumn(29-1, tibia_assistance_force_vy);
%         forceData.setDataColumn(31-1, tibia_assistance_force_px);
%         forceData.setDataColumn(32-1, tibia_assistance_force_py);
% 
%         % print data of external forces to .mot file
%         forceData.print('uphill_walking_calibrated_forces.mot');
% 
%         %% execute inverse dynamics analysis
%         idTool = InverseDynamicsTool('Setup_ID.xml'); % configure ID Tool
%         idTool.setModel(model);
%         idTool.run();
% 
%         %% display logger information (optional)
%         % if simConfig.showLog
%         %     while ~feof(loggerFile)
%         %         l = fgetl(loggerFile);
%         %         disp(l);
%         %     end
%         %     fseek(loggerFile, 0, 'eof');
%         % end
% 
%         %% execute static optimization analysis
%         soTool = AnalyzeTool('Setup_SO.xml');
%         soTool.run();
% 
%         %% display logger information (optional)
%         % if simConfig.showLog
%         %     while ~feof(loggerFile)
%         %         l = fgetl(loggerFile);
%         %         disp(l);
%         %     end
%         %     fseek(loggerFile, 0, 'eof');
%         % end
% 
%         %% execute joint reaction analysis
% 
%         jraTool = AnalyzeTool('Setup_JRA.xml');
%         jraTool.run();
% 
%         %% display logger information (optional)
%         % if simConfig.showLog
%         %     while ~feof(loggerFile)
%         %         l = fgetl(loggerFile);
%         %         disp(l);
%         %     end
%         %     fclose(loggerFile);
%         % end
%         % toc
% 
%         %% read & store jra calculations
%         jraData = Storage('Joint Reaction Analysis\model_scaled_JointReaction_ReactionLoads.sto');
%         jraX = ArrayDouble();
%         jraY = ArrayDouble();
%         jraZ = ArrayDouble();
%         jraData.getDataColumn(0, jraX);
%         jraData.getDataColumn(1, jraY);
%         jraData.getDataColumn(2, jraZ);
%         jraCurve = nan(1, jraData.getSize);
%         for i = 0 : jraData.getSize-1
%             jraCurve(i+1) = sqrt(jraX.get(i)^2 + jraY.get(i)^2 + jraZ.get(i)^2);
%         end
%         jraResults(idxLT, idxS).jraCurve = jraCurve;
%         jraResults(idxLT, idxS).report = report;
% 
%         % time = toc;        
%         % disp(['finished at [lt  s  rt  rs]=[', num2str([lt s rt rs]), ']. calculation time = ', num2str(time), ' sec.']);
%         % fprintf(OptReporter, ['finished at [lt  s  rt  rs]=[', num2str([lt s rt rs]), ']. calculation time = ', num2str(time), ' sec.\n']);
%         disp([char(datetime) ': finished at [lt  s  rt  rs]=[', num2str([lt s rt rs]), '].']);
%         fprintf(OptReporter, [char(datetime) ': finished at [lt  s  rt  rs]=[', num2str([lt s rt rs]), '].\n']);
% 
%     end
%     save jraResults jraResults
% end