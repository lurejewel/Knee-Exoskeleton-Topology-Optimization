ltList = 0.05:0.01:0.30;
sList = 0.05:0.01:0.20;

nLT = length(ltList);
nS = length(sList);

[idxLT, idxS] = ndgrid(1:nLT, 1:nS);
idxLT = idxLT(:);
idxS = idxS(:);

nComb = length(idxLT);
jraResultsArray(nComb) = struct('jraCurve', [], 'report', []);

parfor idx = 1 : nComb
    lt = ltList(idxLT(idx));
    s = sList(idxS(idx));
    result = struct();
    result.jraCurve = [];
    result.report = [lt s];
    jraResultsArray(idx) = result;
end

jraResults = reshape(jraResultsArray, nLT, nS);