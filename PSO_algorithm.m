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
% import org.opensim.modeling.*

%% algorithm preparation
% read model
model = org.opensim.modeling.Model('scaled_model.osim');
state = model.initSystem();
% open reporter
optimOptions.optReporter = fopen('Joint Reaction Analysis\optimization report.txt', 'w');
% optimization options
optimOptions.lb = [0.05, 0.05, 0.08, 0.06, 5, 5, 10]; % lower bound
optimOptions.ub = [0.25, 0.10, 0.15, 0.15, 55, 55, 60]; % upper bound
optimOptions.swarmSize = 12;
optimOptions.init = [0.212944737278636, 0.0985296390880308, 0.139439051410814, 0.0641554251568039, 14.3436302277189, 29.9182025991071, 37.3607764981902];
% [0.250000000000000,0.100000000000000,0.150000000000000,0.084733968350238,5,55,60]; % 2.4025
% [0.23, 0.08, 0.14, 0.10, 10, 40, 50]; % initial guess of all/partial particle positions

% evaluation function
optimOptions.evalFcn = @(exoConfig) KCF_analysis(exoConfig, model, init_opensim_data(), optimOptions.optReporter);

% initialize optimization object
% load("optimizationHistory.mat");
% optimizer = PSO(optimOptions, recorder_);
optimizer = PSO(optimOptions);

% execute particle swarm optimization
[gb, gbfit, exitflag] = optimizer.run

fclose(optimOptions.optReporter);