% RunGetFolderTrialsStatistics
types = {'R', 'P', 'BP'};
eyesTypes = {'O', 'C'};
cfg.inputDir = 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced';

for i = 1: length(types)
    cfg.type = types{i};
    for j = 1:length(eyesTypes)
        cfg.eyes = eyesTypes{j};
        [N, XAXIS, NAMES] = getFolderTrialsStatistics(cfg);
    end
end

