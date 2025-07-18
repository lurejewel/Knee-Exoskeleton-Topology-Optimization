% optimizing x^2 + y^2 + z^2 = 0

clear

x_init = [129 23 190]';
lb =[1 3 pi]'; ub = [99 99 99]';
k = 2;
f = @(x) fcn(x, k);



%% LM method
% options = optimoptions('lsqnonlin', 'Algorithm','levenberg-marquardt','Display','iter-detailed');
% x_opt = lsqnonlin(f, x_init, lb, ub, options);


%% PSO method

options = optimoptions('particleswarm', 'SwarmSize', 5, 'HybridFcn','fmincon', 'Display','iter', 'MaxStallIterations',50, 'MinNeighborsFraction',0.5);
[x_opt, fval, exitflag, output, points] = particleswarm(f, length(x_init), lb, ub, options);


%% cost function
function f = fcn(x, ~)
% x: nx1 array
% f: 1x1 double

f = x(1)^2 + (x(2)-pi)^2 + (x(3)+pi)^2;

end
