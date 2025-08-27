clear; close all; clc
import org.opensim.modeling.*

%% load logger and model
% reporter
OptReporter = fopen('Joint Reaction Analysis\optimization report.txt', 'w');

% model
model = Model('scaled_model.osim');
state = model.initSystem();

%% optimization config
optConfig.init = [% 0.2381910163    0.09410114231     0.1493101661    0.07636484612; % jraPeakHS = 1852 N; fit = 2.48.
    % 0.241322391055357	0.0956705349510876	0.149342114298494	0.0829772070591885; % 1854.995 N
    % 0.2415 0.053576 0.13202 0.060547; % error occured
    0.23 0.09 0.13 0.1; %
    ];
% optConfig.init = [0.20, 0.09, 0.1, 0.08]'*1; % initial guess of [lt s rt rs]'
optConfig.lb = [0.05, 0.05, 0.08, 0.06]'; % lower bound
optConfig.ub = [0.25, 0.1, 0.15, 0.15]'; % upper bound
optConfig.tempData = init_opensim_data();
optConfig.options = optimoptions('particleswarm', 'SwarmSize',15, 'HybridFcn','fmincon', 'Display','iter', 'MinNeighborsFraction',0.5, 'InitialPoints',optConfig.init, 'UseParallel',false, 'OutputFcn', @outputFcn);

%% prepare data of external forces

[exo_force, theta] = cal_force_and_knee_angle();
KCF_optFcn = @(exoConfig) KCF_analysis(exoConfig, model, exo_force, theta, optConfig.tempData, OptReporter);
% [jraPeakHS_opt = lsqnonlin(jraPeakHS, optConfig.init, optConfig.lb, optConfig.ub, optConfig.options);
[x_opt, jraPeakHS_opt, exitflag, output, points] = particleswarm(KCF_optFcn, 4, optConfig.lb, optConfig.ub, optConfig.options)

fclose(OptReporter);