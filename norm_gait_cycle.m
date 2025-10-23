function dataN = norm_gait_cycle(data)

% input: jra data, 1x501
% time of heel strike (grf > 100 N)             index
% 95.010 s                                      2
% 96.383 s                                      139
% 97.710 s                                      272
% 99.019 s                                      402

data_1 = interp1(1:139-2, data(2:138), linspace(1, 139-2, 1000), "linear");
data_2 = interp1(1:272-139, data(139:271), linspace(1, 272-139, 1000), "linear");
data_3 = interp1(1:402-272, data(272:401), linspace(1, 402-272, 1000), "linear");
dataN = mean([data_1; data_2; data_3]);

end