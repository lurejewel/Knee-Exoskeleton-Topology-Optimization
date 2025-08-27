classdef PSO < handle

    properties

        % constant params
        lb % lower bound
        ub % upper bound
        nDim % #dimension of a particle
        swarmSize % #particles in a swarm
        tolerance % minimal change accepted in best fit
        maxIterations % max #iterations
        maxStallIterations % max #iterations since change of gbfit < tolerance
        minNeighborsFraction % indicates the range of sight of a particle
        inertiaRange % 2 x 1 vector, gives the lower and upper bound of the adaptive inertia
        y1 % self adjustment weight
        y2 % social adjustment weight

        % time-varying params
        c % stall counter, #iterations since change of gbfit < tolerance
        n % iteration counter
        N % neighborhood size
        W % inertia

        % swarm info
        pos % [swarmSize x nDim] positions of all particles in the current swarm
        vel % [swarmSize x nDim] velocities of all particles in the current swarm
        fits % [swarmSize x 1] the fitness of all particles in the current swarm
        gb % [1 x nDim] position of the global best particle during the iteration
        gbfit % fitness of gb
        pb % [swarmSize x nDim] best positions of each particles during the iteration
        pbfits % [swarmSize x 1] fitnesses of pb

        % flag, recorder & reporter
        exitflag % 9: under way
        % 1: c > maxStallIterations
        % 0: n > maxIterations
        recorder
        optReporter

        % evaluation function
        evalFcn

    end

    methods

        function obj = PSO(varargin)

            options = varargin{1};

            % constant params
            obj.lb = options.lb;
            obj.ub = options.ub;
            obj.nDim = length(options.lb);
            obj.swarmSize = options.swarmSize;
            obj.tolerance = 1e-6;
            obj.maxIterations = 200 * obj.nDim;
            obj.maxStallIterations = 30;
            obj.minNeighborsFraction = 0.5;
            obj.inertiaRange = [0.1, 1.1];
            obj.y1 = 1.49;
            obj.y2 = 1.49;

            % flag, recorder & reporter
            obj.exitflag = 9; % 9 = optimization under way
            obj.optReporter = options.optReporter;

            % evaluation function
            obj.evalFcn = options.evalFcn;

            if nargin == 1 % first initialization
                % time-varying params
                obj.c = 0;
                obj.n = 0;
                obj.N = max(2, floor(obj.swarmSize*obj.minNeighborsFraction));
                obj.W = max(obj.inertiaRange);

                obj.recorder = [];

                % swarm info
                if height(options.init) >= obj.swarmSize % over-initialized / exactly initialized
                    obj.pos = options.init(1:obj.swarmSize, :);
                else % under-initialized
                    obj.pos(1:height(options.init),:) = options.init;
                    obj.pos(height(options.init)+1:obj.swarmSize,:) = obj.generate_random_particles(obj.swarmSize-height(options.init), obj.nDim);
                end
                obj.vel = ( 2*rand(obj.swarmSize, obj.nDim)-1 ) .* ( obj.ub-obj.lb );
                obj.fits = nan(obj.swarmSize, 1);
                obj.pb = obj.pos;
                obj.pbfits = Inf * ones(obj.swarmSize, 1);
                obj.gb = [];
                obj.gbfit = Inf;

            elseif nargin == 2 % after an unfinished (or finished) optimization

                recorder = varargin{2};
                obj.recorder = recorder;
                obj.c = recorder(end).c;
                obj.n = recorder(end).n;
                obj.N = recorder(end).N;
                obj.W = recorder(end).W;
                obj.pos = recorder(end).swarmPos;
                obj.vel = recorder(end).swarmVel;
                obj.fits = recorder(end).swarmfVal;
                obj.pb = recorder(end).pb;
                obj.pbfits = recorder(end).pbfits;
                obj.gb = recorder(end).gb;
                obj.gbfit = recorder(end).gbfit;

            end

        end

        function randPos = generate_random_particles(obj, height, width)

            lb_ = obj.lb;
            ub_ = obj.ub;
            randPos = nan(height, width);
            for i = 1 : width
                range = ub_(i) - lb_(i);
                if range < 0
                    error('the lower bound is larger than the upper bound.');
                else
                    randPos(:,i) = lb_(i) + range * rand(height,1);
                end
            end

        end

        function [gb, gbfit, exitflag] = run(obj)

            while true % iterating

                progressflag = false;
                for i = 1 : obj.swarmSize

                    % if not the first iteration: update position and velocity
                    % of particle i
                    if obj.n > 0
                        S = randsample(setdiff(1:obj.swarmSize,i), obj.N-1, false); % choose a random subset S of N particles other than i
                        [~, cbidx] = min(obj.pbfits(S)); % communitive best particle's fit and index (among the particle i's neighbors)
                        cb = obj.pb(S(cbidx),:); % position of the communitive best particle
                        u1 = rand(1,4); % uniformly random variable distributed from 0 to 1
                        u2 = rand(1,4); % uniformly random variable distributed from 0 to 1
                        vel_ = obj.W * obj.vel(i,:) + obj.y1 * u1 .* (obj.pb(i,:)-obj.pos(i,:)) + obj.y2 * u2 .* (cb-obj.pos(i,:)); % update the velocity of the particle i
                        pos_ = obj.pos(i,:) + vel_; % update the position of the particle i
                        [obj.pos(i,:), obj.vel(i,:)] = obj.clip_particle(pos_, vel_); % enforce the bounds
                    end

                    % evaluate the objective function of particle i
                    obj.fits(i) = obj.evalFcn(obj.pos(i,:));

                    % update pb, pbfits, gb, gbfit
                    if obj.fits(i) < obj.pbfits(i) % update pb
                        obj.pb(i,:) = obj.pos(i,:);
                        obj.pbfits(i) = obj.fits(i);
                        if obj.fits(i) < obj.gbfit % update gb
                            obj.gb = obj.pos(i,:);
                            obj.gbfit = obj.fits(i);
                            progressflag = true;
                        end
                    end

                end

                % update iteration number
                obj.n = obj.n+1;

                % update time-varying params
                if progressflag % gbfit was lowered
                    obj.c = max(0,obj.c-1);
                    obj.N = floor(obj.swarmSize*obj.minNeighborsFraction);
                    if obj.c < 2
                        obj.W = obj.W*2;
                    elseif obj.c > 5
                        obj.W = obj.W/2;
                    end
                    obj.W(obj.W<obj.inertiaRange(1)) = obj.inertiaRange(1);
                    obj.W(obj.W>obj.inertiaRange(2)) = obj.inertiaRange(2);
                else
                    obj.c = obj.c + 1;
                    obj.N = min(obj.N+floor(obj.swarmSize*obj.minNeighborsFraction), obj.swarmSize);
                end

                % display information
                % fprintf('#iteration (n)\t#stall iteration (c)\tbest fit (gbfit)\n');
                % fprintf('%d\t%d\t%d\n', obj.n, obj.c, obj.gbfit);
                disp(['iter ' num2str(obj.n) ': c=' num2str(obj.c) ', gbfit=' num2str(obj.gbfit)]);
                obj.recorder(obj.n).c = obj.c;
                obj.recorder(obj.n).n = obj.n;
                obj.recorder(obj.n).N = obj.N;
                obj.recorder(obj.n).W = obj.W;
                obj.recorder(obj.n).swarmPos = obj.pos;
                obj.recorder(obj.n).swarmVel = obj.vel;
                obj.recorder(obj.n).swarmfVal = obj.fits;
                obj.recorder(obj.n).pb = obj.pb;
                obj.recorder(obj.n).pbfits = obj.pbfits;
                obj.recorder(obj.n).gb = obj.gb;
                obj.recorder(obj.n).gbfit = obj.gbfit;
                recorder_ = obj.recorder;
                save('optimizationHistory_2.mat', 'recorder_');

                % check exit conditions
                if obj.n > obj.maxIterations
                    obj.exitflag = 0;
                elseif obj.c > obj.maxStallIterations
                    obj.exitflag = 1;
                end

                % prepare outputs for exiting
                if obj.exitflag ~= 9
                    gb = obj.gb;
                    gbfit = obj.gbfit;
                    exitflag = obj.exitflag;
                    break;
                end

            end
        end

        function [clippedPos, clippedVel] = clip_particle(obj, pos, vel)
            clippedPos = pos;
            clippedPos(pos>obj.ub) = obj.ub(pos>obj.ub);
            clippedPos(pos<obj.lb) = obj.lb(pos<obj.lb);

            clippedVel = vel;
            clippedVel(clippedPos==obj.ub) = 0;
            clippedVel(clippedPos==obj.lb) = 0;

        end

    end
end