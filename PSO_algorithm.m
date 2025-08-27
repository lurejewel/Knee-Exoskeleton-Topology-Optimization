% Input:
% - evalFcn: evaluation function. calculate fitness given the particle.
% - ndim: #dimensions of the particle (ndimx1 vector).
% - lb: lower bound of the optimization problem.
% - ub: upper bound of the optimization problem.
% - init: initial guess of particle positions.
% 
% Output:
% - x_opt: position of the optimal particle.
% - fval_opt: fitness of the optimal particle.
% - exitflag: type of exit condition triggered.
% - output: output function. called once per iteration.
% - points: position of particles in the last iteration.

clear; close all; clc
import org.opensim.modeling.*

%% algorithm preparation
% read model
model = Model('scaled_model.osim');
state = model.initSystem();
% open reporter
optimOptions.optReporter = fopen('Joint Reaction Analysis\optimization report.txt', 'w');
% optimization options
optimOptions.lb = [0.05, 0.05, 0.08, 0.06]; % lower bound
optimOptions.ub = [0.25, 0.10, 0.15, 0.15]; % upper bound
optimOptions.swarmSize = 15;
optimOptions.init = [0.23, 0.09, 0.13, 0.10]; % initial guess of all/partial particle positions
% [0.23819 0.09410 0.14931 0.07636]; 

% evaluation function
[exo_force, theta] = cal_force_and_knee_angle;
optimOptions.evalFcn = @(exoConfig) KCF_analysis(exoConfig, model, exo_force, theta, init_opensim_data, optimOptions.optReporter);

% initialize optimization object
% load("optimizationHistory_2.mat");
% optimizer = PSO(optimOptions, recorder_);
optimizer = PSO(optimOptions);

% execute particle swarm optimization
[gb, gbfit, exitflag] = optimizer.run

fclose(optimOptions.optReporter);