
%% Set Frequency Limits
foilim = [1 4 ; 4 8 ; 8 13 ; 13 24; 24 30];

%% Load data, take trials of specific conditions using getTrials.

% load('C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pWA1993\pWA1993_post_ICA_2_components.mat')
% 
% trialTypes = unique(postIcaData.trialtype)
% 
% cfg = [];
% cfg.minlength = 10;
% cfg.maxlength = 10;
% cfg.segmenttrials = 'yes';
% 
% cfg.trialtypes = trialTypes([2]);
% PsTrials = getTrials(cfg, postIcaData);
% 
% cfg = [];
% cfg.minlength = 10;
% cfg.maxlength = 10;
% cfg.segmenttrials = 'yes';
% 
% cfg.trialtypes = trialTypes([4]);
% RestTrials = getTrials(cfg, postIcaData);

%%
figure
for foilimI = 1:size(foilim,1)
    %% REST
    cfg = [];
    cfg.foilim = foilim(foilimI,:);
    [filteredDataRest envelopeDataRest] = getEnvelope(cfg, RestTrials3);

    % checkEnvelope(filteredDataRest, envelopeDataRest, 1);

    cfg = [];
    cfg.roisFile = 'C:\Users\Roey\Documents\Lab\PNES Project\PNES\atlas_rois\EEG_labels.xls'

    cohRest = getCohMatrix(cfg, envelopeDataRest);

    save(['C:\Users\Roey\Documents\Lab\PNES Project\check_TI_in_electrodes_space\pWA1993_rest_' , num2str(foilim(foilimI,1)) '_' num2str(foilim(foilimI, 2)) '.mat'], 'cohRest')

    %% SEIZURE

    cfg = [];
    cfg.foilim = foilim(foilimI,:);
    [filteredDataSeiz envelopeDataSeiz] = getEnvelope(cfg, PsTrials);

    % checkEnvelope(filteredDataSeiz, envelopeDataSeiz, 1);

    cfg = [];
    cfg.roisFile = 'C:\Users\Roey\Documents\Lab\PNES Project\PNES\atlas_rois\EEG_labels.xls'
    cohSeiz = getCohMatrix(cfg, envelopeDataSeiz);
    save(['C:\Users\Roey\Documents\Lab\PNES Project\check_TI_in_electrodes_space\pWA1993_seiz_' , num2str(foilim(foilimI,1)) '_' num2str(foilim(foilimI, 2)) '.mat'], 'cohRest')
    %% Compute TI
    meanCohRest = mean(cohRest.cohspctrm);
        TIRest = -log(1-meanCohRest);
    meanCohSeiz = mean(cohSeiz.cohspctrm);
        TISeiz = -log(1-meanCohSeiz);
    % figure; hold all
    % plot(cohRest.freq, TIRest)
    % plot(cohRest.freq, TISeiz)
    % title(['Total Interdependence in ' num2str(foilim(1)), '-' num2str(foilim(2)) ' Hz'])
    % ylabel('Total Interdependence');
    % xlabel('Frequency (Hz)');
    % legend('Rest', 'PNES')

%     figure
    subplot(2,3,foilimI)
    semilogx(cohRest.freq, TIRest, cohRest.freq, TISeiz)
    xlim([0, cohRest.freq(end)]);
    title(['Total Interdependence in electrode space, '  num2str(foilim(foilimI, 1)), '-' num2str(foilim(foilimI, 2)) ' Hz'])
    ylabel('Total Interdependence');
    xlabel('Frequency (Hz)');
    legend('Rest', 'PNES')
end

tightfig