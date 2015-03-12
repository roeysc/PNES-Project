%% Get EEG correlation matrix from rest in aal

%% Load Data in Source Space
data = load2struct('C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\check network\srcVirChanRest.mat')

%% 
foilim = [1 4; 4 8 ; 8 13 ; 13 24; 24 30];

for foilimI = 1:size(foilim,1)
    cfg = [];
    cfg.foilim = foilim(foilimI,:);
    foilimStr = [num2str(foilim(foilimI,1)), '_', num2str(foilim(foilimI,2)) ];
    eval(['   [filteredDataRest_' foilimStr  ', envelopeDataRest_' foilimStr '] = getEnvelope(cfg, data);   '])
end

checkEnvelope(filteredDataRest_8_13, envelopeDataRest_8_13, 2);

%% Create Correlation Matrix
histFigure = figure;
corrMatAll = {};
for foilimI = 1:size(foilim,1)
    
    foilimStr = [num2str(foilim(foilimI,1)), '_', num2str(foilim(foilimI,2)) ];
    eval(['data = filteredDataRest_' foilimStr  ';'])

    corrMat = zeros(length(data.label));

    for i = 2:length(data.trial)
        corrMat = corrMat + corr(data.trial{i}')
    end
    corrMat = corrMat/length(data.trial);
    corrMatAll{foilimI} = corrMat;
    plot_matrix(corrMat)
    foilimStr(foilimStr == '_') = '-';

    title([ 'filteredDataRest ' foilimStr ]);
    
    figure(histFigure)
    subplot(2,3,foilimI)
    hist(corrMat(:),20) % this suggests we might need to orthogonalize that data
    xlim([-0.5,1]);
    title([ 'filteredDataRest ' foilimStr ]);
end

%% Contacanate data to one trial
dataOneTrial = zeros(size(data.trial{1},1));
for trialI = 1:length(data.trial)
    dataOneTrial = [dataOneTrial, data.trial{trialI}];
end

%% Cluster Data according to correlation

treeFigure = figure;

% Create one continuous trial
for foilimI = 1:size(foilim,1)
    foilimStr = [num2str(foilim(foilimI,1)), '_', num2str(foilim(foilimI,2)) ];
    eval(['data = filteredDataRest_' foilimStr  ';'])
    
    linkageMethod = 'median';
    [Z T] = clusterdata_return_z(dataOneTrial ,'distance', 'correlation', 'linkage', linkageMethod, 'maxclust', 6); %maxclust or cutoff
    
    figure(treeFigure);
    foilimStr(foilimStr == '_') = '-';
    subplot(2,3,foilimI)
    dendrogram(Z)
    title([ 'filteredDataRest ' foilimStr ]);
    
    % Get the cluster of each ROI
    i = 0;
    roisPerCluster = cell(1,length(unique(T)));
    
    foilimStr = [num2str(foilim(foilimI,1)), '_', num2str(foilim(foilimI,2)) ];
    for i = 1:length(T)
        roisPerCluster{T(i)} = [roisPerCluster{T(i)}, data.label(i)];
    end
    
    eval(['roisPerCluster_Rest_' foilimStr  ' = roisPerCluster;'])

end
tightfig
%% Cluster Data after z-sccore according to correlation
treeFigure = figure;

for foilimI = 1:size(foilim,1)
    foilimStr = [num2str(foilim(foilimI,1)), '_', num2str(foilim(foilimI,2)) ];
    eval(['data = filteredDataRest_' foilimStr  ';'])
    
    dataOneTrial_z = zeros(size(data.trial{1},1));
    for trialI = 1:length(data.trial) % NOTE: each trial is transformed seperately
        dataOneTrial_z = [dataOneTrial, zscore(data.trial{trialI}, 0, 1)];
    end
    
    linkageMethod = 'centroid';
    [Z T] = clusterdata_return_z(dataOneTrial_z,'distance', 'correlation', 'linkage', linkageMethod, 'maxclust', 6);
    
    figure(treeFigure);
    foilimStr(foilimStr == '_') = '-';
    subplot(2,3,foilimI)
    dendrogram(Z)
    title([ 'filteredDataRest-z ' foilimStr ]);
    
    % Get the cluster of each ROI
    i = 0;
    roisPerCluster = cell(1,length(unique(T)));

    for i = 1:length(T)
        roisPerCluster{T(i)}(end+1) = i;
    end
    
    foilimStr = [num2str(foilim(foilimI,1)), '_', num2str(foilim(foilimI,2)) ];
    
    eval(['roisPerCluster_Rest_z' foilimStr  ' = roisPerCluster;'])

    % Save aal Mask
    aal_mask_file = 'C:\Users\Roey\Documents\MATLAB\Roey_scripts\AAL_resliced_61x73x61_v2_michael.nii';
    
    for clusterI = 1:length(unique(T))
        output_mask_file = ['C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\check network\Rest_', foilimStr '_' linkageMethod '_cluster_' num2str(clusterI) '.nii'];
        make_partial_mask(aal_mask_file, roisPerCluster{clusterI}, output_mask_file)
    end
    
end
tightfig