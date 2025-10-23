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
optimOptions.lb = [0.05, 0.05, 0.08, 0.06, 0, 0, 0]; % lower bound
optimOptions.ub = [0.25, 0.10, 0.15, 0.15, 60, 60, 60]; % upper bound
optimOptions.swarmSize = 20;
optimOptions.init = [0.100170136658438,0.100000000000000,0.080578804115766,0.060036168940929,0.148103074497044,47.453364323808760,60]; % -> 1.8908
% [0.120915252277795,0.05,0.08,0.06,13.528209067334988,13.528209067334988,34.882156639172930];
% [0.23, 0.08, 0.14, 0.10, 10, 40, 50]; % initial guess of all/partial particle positions
% [0.2139, 0.0820, 0.1498, 0.0688, 6.2576, 56.5678, 60] % -> 2.5458(150N)
% [0.23819, 0.09410, 0.14931 0.07636, 9, 39, 51]; % -> 2.4845(175N); 2.6253(150N)
% [0.1001, 0.0999, 0.1500, 0.0611, 16.4408, 32.8239, 55.8860]; % -> 2.7601(175N); 2.8616(150N)

% evaluation function
optimOptions.evalFcn = @(exoConfig) KCF_analysis(exoConfig, model, init_opensim_data(), optimOptions.optReporter);

% initialize optimization object
load("optimizationHistory.mat");
optimizer = PSO(optimOptions, recorder_);
% optimizer = PSO(optimOptions);

% execute particle swarm optimization
[gb, gbfit, exitflag] = optimizer.run

fclose(optimOptions.optReporter);