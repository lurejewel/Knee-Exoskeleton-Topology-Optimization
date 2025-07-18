% test of LM algorithm
% optimizing x^2 + y^2 + z^2 = 0

x_init = [129 23 190]';
lb =[1 2 pi]'; ub = [999 999 9999]';
k = 2;
f = @(x) fcn(x, k);

options = optimoptions('lsqnonlin', 'Algorithm','levenberg-marquardt','Display','iter-detailed');
x_opt = lsqnonlin(f, x_init, lb, ub, options);

function f = fcn(x, k)
% x: nx1 array
% f: 1x1 double
f = x'*x*k;

end
