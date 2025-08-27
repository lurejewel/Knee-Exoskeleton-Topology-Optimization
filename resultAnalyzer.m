%% PSO result analysis

load optimizationHistory_1.mat
% colorArr = [linspace(1,0,length(info))', zeros(length(info),1), linspace(0,1,length(info))']; % [1 0 0] -> [0 0 1]
% colorArr = linspace(0,1,length(info));
% len = length(info);

%% [X Y Z]=[lt R r]; color=fit
len = round((3.03-2.48)*1000);
colorArr = [ones(len,1), linspace(1,0,len)', zeros(len,1)]; % [1 1 0] -> [1 0 0]
figure, hold on
for i = 1 : length(info)
    for j = 1 : height(info(i).swarm)
        if info(i).swarmfval(j) ~= 9999
            scatter3(info(i).swarm(j,1), info(i).swarm(j,3), info(i).swarm(j,4), [], colorArr(round(1000*(info(i).swarmfval(j)-2.48)),:), 'filled');
        else
            % scatter3(info(i).swarm(j,1), info(i).swarm(j,3), info(i).swarm(j,4), [], [0,0,0], 'filled');
        end
    end
end

%% [X Y Z color]=[lt R r s]; multiple figures

% for i = 1 : length(info)
%     figure(101), hold on
%     scatter3()
% end
% particles(height(info(1).swarm)) = struct('position', nan(length(info),4));
% for i = 1 : length(info)
%     for j = 1 : height(info(i).swarm)
%         particles(j).position(i,:) = info(i).swarm(j,:);
%     end
% end

for i = 1 : length(info)
    figure(100+i), hold on, grid on
    for j = 1 : height(info(i).swarm)
        scatter3(info(i).swarm(j,1), info(i).swarm(j,3), info(i).swarm(j,4), 'filled');
    end
end

% figure, hold on
% for i = 1 : length(info)
%     for j = 1 : height(info(i).swarm)
%         % if info(i).swarmfval(j) ~= 9999
%             scatter3(info(i).swarm(j,1), info(i).swarm(j,2), info(i).swarmfval(j), [], colorArr(i,:), 'filled');
%         % end
%     end
% end
% % colorbar
% 
% figure, hold on
% for i = 1 : length(info)
%     for j = 1 : height(info(i).swarm)
%         % if info(i).swarmfval(j) ~= 9999
%             scatter3(info(i).swarm(j,3), info(i).swarm(j,4), info(i).swarmfval(j), [], colorArr(i,:), 'filled');
%         % end
%     end
% end
% % colorbar
% 
% %% old codes
% 
% load jraResults.mat
% 
% jraN = nan(1000, height(jra), width(jra));
% jraPeak = nan(height(jra), width(jra));
% jraPeakHS = nan(height(jra), width(jra));
% 
% ltList = 0.05:0.01:0.3;
% sList = 0.05:0.01:0.2;
% l0 = 0.09;
% for idxLT = 1 : height(jra)
%     for idxS = 1 : width(jra)
% 
%         if ~isnan(sum(jra(idxLT, idxS).jraCurve))
%             temp = norm_gait_cycle(jra(idxLT, idxS).jraCurve);
%             jraN(:, idxLT, idxS) = temp;
%             jraPeak(idxLT, idxS) = max(temp);
%             jraPeakHS(idxLT, idxS) = max(temp(1:250));
% 
%             lt = ltList(idxLT);
%             s = sList(idxS);
%             lc = l0+2*s-lt;
%             if (lc <= 0.04) || (lc >=0.25) || (lc+s >= 0.3) || (s > 0.1) || (lt <= 0.1)
%                 jraPeakHS(idxLT, idxS) = nan;
%             end
%         end
% 
%     end
% end
% 
% [X, Y] = meshgrid(.05:.01:.2, .05:.01:.3);
% figure, mesh(X, Y, jraPeakHS);
% 
% 
% 
% 
% 
% %% functions
% function dataN = norm_gait_cycle(data)
% 
% % input: jra data, 1x501
% % 26.714 s (72): heel strike (grf > 0)
% % 27.848 s (186): heel strike
% % 28.948 s (296): heel strike
% % 30.057 s (407): heel strike
% data_1 = interp1(1:186-72, data(72:185), linspace(1, 186-72, 1000), "linear");
% data_2 = interp1(1:296-186, data(186:295), linspace(1, 296-186, 1000), "linear");
% data_3 = interp1(1:407-296, data(296:406), linspace(1, 407-296, 1000), "linear");
% dataN = mean([data_1; data_2; data_3]);
% 
% end