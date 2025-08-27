import org.opensim.modeling.*

%% read data from files

jrafile = './Joint Reaction Analysis/model_scaled_JointReaction_ReactionLoads.sto';
jrafile_no_exo = './Joint Reaction Analysis/EXO_IGNORED_JointReaction_ReactionLoads.sto';
jrafile_no_assist = './Joint Reaction Analysis/EXO_OFF_JointReaction_ReactionLoads.sto';

jra_exoAssist_musReduced = Storage(jrafile);
jra_musReduced = Storage(jrafile_no_exo);
jra_noAssist = Storage(jrafile_no_assist);

%% calculate resultant joint reaction forces

fx = ArrayDouble();
fy = ArrayDouble();
fz = ArrayDouble();
jra_exoAssist_musReduced.getDataColumn(0,fx);
jra_exoAssist_musReduced.getDataColumn(1,fy);
jra_exoAssist_musReduced.getDataColumn(2,fz);
for i = 0 :jra_exoAssist_musReduced.getSize-1
    jraCurve_exoAssist_musReduced(i+1) = sqrt(fx.get(i)^2 + fy.get(i)^2 + fz.get(i)^2);
end

fx = ArrayDouble();
fy = ArrayDouble();
fz = ArrayDouble();
jra_musReduced.getDataColumn(0,fx);
jra_musReduced.getDataColumn(1,fy);
jra_musReduced.getDataColumn(2,fz);
for i = 0 :jra_musReduced.getSize-1
    jraCurve_musReduced(i+1) = sqrt(fx.get(i)^2 + fy.get(i)^2 + fz.get(i)^2);
end

fx = ArrayDouble();
fy = ArrayDouble();
fz = ArrayDouble();
jra_noAssist.getDataColumn(0,fx);
jra_noAssist.getDataColumn(1,fy);
jra_noAssist.getDataColumn(2,fz);
for i = 0 :jra_no_mus_no_exo.getSize-1
    jraCurve_noAssist(i+1) = sqrt(fx.get(i)^2 + fy.get(i)^2 + fz.get(i)^2);
end

%% display data

figure, plot(jraCurve_exoAssist_musReduced), hold on, plot(jraCurve_musReduced), plot(jraCurve_noAssist)
legend('exo assist, muscle reduced', 'exo ignored, muscle reduced', 'exo off');