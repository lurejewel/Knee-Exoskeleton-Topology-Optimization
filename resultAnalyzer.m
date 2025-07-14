load jraResults.mat

jraN = nan(1000, height(jra), width(jra));
jraPeak = nan(height(jra), width(jra));
jraPeakHS = nan(height(jra), width(jra));
for idxLT = 1 : height(jra)
    for idxS = 1 : width(jra)

        if ~isnan(sum(jra(idxLT, idxS).jraCurve))
            temp = norm_gait_cycle(jra(idxLT, idxS).jraCurve);
            jraN(:, idxLT, idxS) = temp;
            jraPeak(idxLT, idxS) = max(temp);
            jraPeakHS(idxLT, idxS) = max(temp(1:250));
        end

    end
end

[X, Y] = meshgrid(.05:.01:.2, .05:.01:.3);
figure, mesh(X, Y, jraPeakHS);





%% functions
function dataN = norm_gait_cycle(data)

% input: jra data, 1x501
% 26.714 s (72): heel strike (grf > 0)
% 27.848 s (186): heel strike
% 28.948 s (296): heel strike
% 30.057 s (407): heel strike
data_1 = interp1(1:186-72, data(72:185), linspace(1, 186-72, 1000), "linear");
data_2 = interp1(1:296-186, data(186:295), linspace(1, 296-186, 1000), "linear");
data_3 = interp1(1:407-296, data(296:406), linspace(1, 407-296, 1000), "linear");
dataN = mean([data_1; data_2; data_3]);

end