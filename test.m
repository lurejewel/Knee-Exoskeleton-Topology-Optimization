% optimizing x^2 + y^2 + z^2 = 0

clear

x_init = [129 23 190]';
lb =[1 3 pi]'; ub = [99 99 99]';
k = 2;
fcn_ = @(x) fcn(x, k);
iter = 0;


%% LM method
% options = optimoptions('lsqnonlin', 'Algorithm','levenberg-marquardt','Display','iter-detailed');
% x_opt = lsqnonlin(f, x_init, lb, ub, options);


%% PSO method

options = optimoptions('particleswarm', 'SwarmSize', 5, 'HybridFcn','fmincon', 'Display','iter', 'MaxStallIterations',50, 'MinNeighborsFraction',0.5, 'OutputFcn', @outputFcn);
[x_opt, fval, exitflag, output, points] = particleswarm(fcn_, length(x_init), lb, ub, options);


%% cost function
function f = fcn(x, k)
% x: nx1 array
% f: 1x1 double
f = x(1)^2 + (x(2)-pi)^2 + (x(3)+pi)^2*k;
disp(f);
end

%% output function
function stop = outputFcn(optimValues, state)

persistent swarmHistory;
disp(optimValues.iteration);
stop = false;

if state == 'init'
    swarmHistory = [];
end
swarmHistory(optimValues.iteration+1).swarm = optimValues.swarm;
swarmHistory(optimValues.iteration+1).swarmfval = optimValues.swarmfvals;
save('swarmHistory.mat', 'swarmHistory');

end
