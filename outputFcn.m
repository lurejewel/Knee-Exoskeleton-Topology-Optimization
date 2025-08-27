function stop = outputFcn(optimValues, state)

persistent info;
stop = false;

if state == 'init'
    info = [];
end

info(optimValues.iteration+1).swarm = optimValues.swarm;
info(optimValues.iteration+1).swarmfval = optimValues.swarmfvals;
save('optimizationHistory.mat', 'info');

end