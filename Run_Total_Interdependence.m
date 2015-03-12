%% REST
sourceTrialsRest = RunSourceAnalysisTmp('C:\Users\Roey\Documents\Lab\PNES Project\PNES\DB\rereferenced\queries\RestOpen.mat')
srcVirChanRest = getSourceVirtualChannels([], sourceTrialsRest)

cfg = [];
cfg.foilim = [13 24];
[filteredDataRest envelopeDataRest] = getEnvelope(cfg, srcVirChanRest);

checkEnvelope(filteredDataRest, envelopeDataRest, 1);

cfg.roisFile = 'C:\Users\roeysc\Desktop\PNES\hippocampus_rois.xlsx';
cohRest = getCohMatrix(cfg, envelopeDataRest);

%% SEIZURE
sourceTrialsSeiz = RunSourceAnalysisTmp('C:\Users\Roey\Documents\EEG_PNES\DB_Lakech\rereferenced\queries\LG_P.mat')
srcVirChanSeiz = getSourceVirtualChannels([], sourceTrialsSeiz)

cfg = [];
cfg.foilim = [13 24];
[filteredDataSeiz envelopeDataSeiz] = getEnvelope(cfg, srcVirChanSeiz);

plotEnvelope(filteredDataSeiz, envelopeDataSeiz, 1);

cfg.roisFile = 'C:\Users\Roey\Documents\hippocampus_rois.xlsx';
cohSeiz = getCohMatrix(cfg, envelopeDataSeiz);
save('C:\Users\Roey\Documents\EEG_PNES\DB_Lakech\rereferenced\queries\coh_SEIZ.mat', 'cohSeiz')

%% Compute TI
meanCohRest = mean(cohRest.cohspctrm);
    TIRest = -log(1-meanCohRest);
meanCohSeiz = mean(cohSeiz.cohspctrm);
    TISeiz = -log(1-meanCohSeiz);
figure; hold all
plot(cohRest.freq, TIRest)
plot(cohRest.freq, TISeiz)

