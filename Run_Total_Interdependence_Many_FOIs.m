
%% Set Frequency Limits
foilim = [1 4 ; 4 8 ; 8 13 ; 13 24; 24 30];
network = 'hippocampus'; % acc ; hippocampus ; insula ; parietal_inferior ; parietal_superior ; posterior_cingulate

figure;
% Rest
sourceTrialsRest = RunSourceAnalysisNew(RestTrials); % TODO: change to New when done
cfg.atlasPath = which('aal_memory_clusters.nii');
cfg.atlasPath = which('aal_memory_clusters.nii');
srcVirChanRest = getSourceVirtualChannels(cfg, sourceTrialsRest);
% 
% % Seizure
sourceTrialsSeiz = RunSourceAnalysisNew(PsTrials);  % TODO: change to New when done
cfg.atlasPath = which('aal_memory_clusters.nii');
srcVirChanSeiz = getSourceVirtualChannels(cfg, sourceTrialsSeiz);

%%
for foilimI = 1:size(foilim,1)
    % REST
    cfg = [];
    cfg.foilim = foilim(foilimI,:);
    [filteredDataRest envelopeDataRest] = getEnvelope(cfg, srcVirChanRest);

%     checkEnvelope(filteredDataRest, envelopeDataRest, 1);

    cfg = [];
    cfg.roisFile = ['C:\Users\Roey\Documents\Lab\PNES Project\PNES\atlas_rois\' network '.xls'];


    cohRest = getCohMatrix(cfg, envelopeDataRest);

%     save(['C:\Users\Roey\Documents\Lab\PNES Project\TiResults\pYA_ME\coh_Rest_CHECK_' network, '_' num2str(foilim(foilimI,1)) '_' num2str(foilim(foilimI, 2)) '.mat'], 'cohRest')

    % SEIZURE

    cfg = [];
    cfg.foilim = foilim(foilimI,:);
    [filteredDataSeiz envelopeDataSeiz] = getEnvelope(cfg, srcVirChanSeiz);

    % checkEnvelope(filteredDataSeiz, envelopeDataSeiz, 1);

    cfg = [];
    cfg.roisFile = ['C:\Users\Roey\Documents\Lab\PNES Project\PNES\atlas_rois\' network '.xls'];
    cohSeiz = getCohMatrix(cfg, envelopeDataSeiz);
%     save(['C:\Users\Roey\Documents\Lab\PNES Project\TiResults\pYA_ME\coh_Seiz_CHECK_' network, '_' num2str(foilim(foilimI, 1)) '_' num2str(foilim(foilimI, 2)) '.mat'], 'cohSeiz')

    
    %% Compute TI
    meanCohRest = mean(cohRest.cohspctrm);
        TIRest = -log(1-meanCohRest);
    meanCohSeiz = mean(cohSeiz.cohspctrm);
        TISeiz = -log(1-meanCohSeiz);
    
        
    % Save coherence matrices values to matrix
    if foilimI == 1;
        cohRestMat = zeros(length(meanCohRest), size(foilim,1));
        cohSeizMat = zeros(length(meanCohSeiz), size(foilim,1));
    end
    cohRestMat(:,foilimI) = meanCohRest;
    cohSeizMat(:,foilimI) = meanCohSeiz;
        
    % Save TI values to matrix
    if foilimI == 1;
        TIRestMat = zeros(length(cohRest.freq), size(foilim,1));
        TISeizMat = zeros(length(cohRest.freq), size(foilim,1));
    end
    TIRestMat(:,foilimI) = TIRest;
    TISeizMat(:,foilimI) = TISeiz;
    
    % figure; hold all
    % plot(cohRest.freq, TIRest)
    % plot(cohRest.freq, TISeiz)
    % title(['Total Interdependence in ' num2str(foilim(1)), '-' num2str(foilim(2)) ' Hz'])
    % ylabel('Total Interdependence');
    % xlabel('Frequency (Hz)');
    % legend('Rest', 'PNES')

end

%% Plot everything
figure
for foilimI = 1:size(foilim,1)
    subplot(2,3,foilimI)
    semilogx(cohRest.freq, TIRestMat(:,foilimI), cohRest.freq, TISeizMat(:,foilimI)); % OR: PLOT
    xlim([0, cohRest.freq(end)]);
%     ylim([0.2, 1.4]);
    title(['Total Interdependence in ' network ', ' num2str(foilim(foilimI, 1)), '-' num2str(foilim(foilimI, 2)) ' Hz'])
    ylabel('Total Interdependence');
    xlabel('Frequency (Hz)');
    
    if foilimI == size(foilim,1)
        legend('Rest', 'PNES')
    end
end

tightfig