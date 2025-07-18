clear; close all; clc
import org.opensim.modeling.*

%% load logger and model
% reporter
OptReporter = fopen('Joint Reaction Analysis\optimization report.txt', 'w');

% model
model = Model('scaled_model.osim');
state = model.initSystem();

%% optimization config

optConfig.init = [0.20, 0.09, 0.1, 0.08]'*1; % initial guess of [lt s rt rs]'
optConfig.lb = [0.05, 0.05, 0.08, 0.06]'*1; % lower bound
optConfig.ub = [0.25, 0.1, 0.15, 0.15]'*1; % upper bound
optConfig.tempData = init_opensim_data();
optConfig.options = optimoptions('particleswarm', 'SwarmSize', 8, 'HybridFcn','fmincon', 'Display','iter', 'MinNeighborsFraction',0.5);

%% prepare data of external forces

[exo_force, theta] = cal_force_and_knee_angle();
KCF_optFcn = @(exoConfig) KCF_analysis(exoConfig, model, exo_force, theta, optConfig.tempData, OptReporter);
% [jraPeakHS_opt = lsqnonlin(jraPeakHS, optConfig.init, optConfig.lb, optConfig.ub, optConfig.options);
[x_opt, jraPeakHS_opt, exitflag, output, points] = particleswarm(KCF_optFcn, length(optConfig.init), optConfig.lb, optConfig.ub, optConfig.options);

fclose(OptReporter);