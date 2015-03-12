%% Source reconstruction
sourceTrials1 = RunSourceAnalysisTmp('C:\Users\Roey\Documents\EEG_check_inverse\DB\rereferenced\queries\RESTOpen.mat')
sourceTrials2 = RunSourceAnalysisTmp('C:\Users\Roey\Documents\EEG_check_inverse\DB\rereferenced\queries\MLROpen.mat')

srcVirChan1 = getSourceVirtualChannels([], sourceTrials1);
srcVirChan2 = getSourceVirtualChannels([], sourceTrials2);


%% Load atalas labels
ftPath = which('ft_defaults');
indices = find(ftPath == filesep);
ftPath(indices(end)+1:end) = [];
atlasPath = [ftPath 'template' filesep 'atlas' filesep 'aal' filesep 'ROI_MNI_V4.nii'];
atlas = ft_read_atlas(atlasPath);
atlas = ft_convert_units(atlas, 'cm');
aal_labels = atlas.tissuelabel;
aal_labels = aal_labels(1:90); % get rid of cerebellum labels
clear ftPath ; clear indices; clear atlas;

% % % %% Filter data
% % % filtercfg = [];
% % % filtercfg.bpfilter = 'yes';
bands = [1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48];
% % % 
% % % filteredDataRest = cell(1,length(bands));
% % % filteredDataMHL  = cell(1,length(bands));
% % % 
% % % for bandI = 1:length(bands)
% % %     filtercfg.bpfreq = bands(bandI,:);
% % %     
% % %     filteredDataRest{bandI} = ft_preprocessing(filtercfg, srcVirChanRest);
% % %     filteredDataMHL{bandI}  = ft_preprocessing(filtercfg, srcVirChanMHL);
% % % end
% % % clear filtercfg; clear bandI;

%% Calculate power
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = aal_labels;
cfg.method       = 'mtmfft'; % why not mtmconvol?
cfg.taper        = 'hanning';
cfg.foi          = mean(bands')';
cfg.keeptrials   = 'yes';
% cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
% cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)

freqData1= ft_freqanalysis(cfg, srcVirChan1);
freqData2  = ft_freqanalysis(cfg, srcVirChan2);
% % % 
% % % 
% % % %% Statistical Test with Permutation
% % % cfg = [];
% % % cfg.channel          =  'all';
% % % cfg.frequency        = mean(bands(3,:)); % TODO: do this for every frequency
% % % cfg.method           = 'montecarlo';
% % % cfg.statistic        = 'ft_statfun_depsamplesT';
% % % cfg.correctm         = 'cluster';
% % % cfg.clusteralpha     = 0.05;
% % % cfg.clusterstatistic = 'maxsum';
% % % cfg.minnbchan        = 2;
% % % cfg.tail             = 0;
% % % cfg.clustertail      = 0;
% % % cfg.alpha            = 0.05;
% % % cfg.numrandomization = 500;
% % % % % specifies with which sensors other sensors can form clusters
% % % % cfg_neighb.method    = 'distance';
% % % % cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, GA_TFRFC);
% % % 
% % % subj = 1;
% % % trialsNumRest = length(sourceTrialsRest.trial);
% % % trialsNumMHL = length(sourceTrialsMHL.trial);
% % % design = zeros(2,trialsNumRest + trialsNumMHL);
% % % design(1,:) = 1;
% % % design(2,1:trialsNumRest) = 1;
% % % design(2,trialsNumRest+1:end) = 2;
% % % 
% % % cfg.design   = design;
% % % cfg.uvar     = 1; % subject (always subject 1)
% % % cfg.ivar     = 2; % condition (Rest(1) or MHL(2))
% % % 
% % % [stat] = ft_freqstatistics(cfg, freqDataRest, freqDataMHL)

%% Statistical Test without Permutation
cfgtmp = [];
cfgtmp.channel = 'all';
cfgtmp.trials = 'all';
cfgtmp.frequency = 'all';
cfgtmp.parameter = 'powspctrm';
cfgtmp.method = 'stats'; %'montecarlo';
cfgtmp.design = [ones(1,size(freqData1.powspctrm,1)), 2.*ones(1,size(freqData2.powspctrm,1))];
cfgtmp.ivar = 1;
cfgtmp.statistic   = 'ttest2'; %ft_statfun_indepsamplesT';
cfgtmp.correctm    = 'bonferoni'; %'cluster';
cfgtmp.numrandomization = 1000;
cfgtmp.alpha       = 0.05;
cfgtmp.tail        = 0;

[stat] = ft_freqstatistics(cfgtmp, freqData1, freqData2);

% make partial masks to visualize the sigificantly different areas in each frequency band
for bandI = 1:length(bands)
    maskname = ['REST_MLR_', num2str(bands(bandI,1)) '_' num2str(bands(bandI,2))];
    make_partial_mask('C:\Users\Roey\Documents\MATLAB\Scripts\Michael_scripts\subfunctions\AAL_resliced_61x73x61_v2_michael.nii', find(stat.mask(:,bandI)), ['C:\Users\Roey\Documents\EEG_check_inverse\Results\' maskname '.nii'])
end


%% Second try of statistical test

% Create one source struct of the two conditions, or try to input both
% sources to ft_sourcestatistics.
% % % 
% % % trialsNum1 = length(sourceTrials1.trial);
% % % trialsNum2 = length(sourceTrials2.trial);
% % % 
% % % cfg = [];
% % % cfg.dim         = sourceTrials1.dim;
% % % cfg.method      = 'montecarlo';
% % % cfg.statistic   = 'ft_statfun_indepsamplesT';
% % % cfg.parameter   = 'pow';
% % % cfg.correctm    = 'fdr'; %'cluster';
% % % cfg.numrandomization = 1000;
% % % cfg.alpha       = 0.05;
% % % cfg.tail        = 0;
% % % cfg.correcttail = 'prob';
% % % 
% % % %since this is only one subject, design should be 1XN and not 2XN;
% % % design = zeros(1,trialsNum1 + trialsNum2);
% % % design(1:trialsNum1) = 1;
% % % design(trialsNum1+1:end) = 2;
% % % cfg.design = design;
% % % 
% % % cfg.atlas        = atlasPath;
% % % cfg.roi          = aal_labels;
% % % cfg.avgoverroi   = 'yes';
% % % cfg.hemisphere   = 'both';
% % % cfg.inputcoord   = 'mni';
% % % 
% % % 
% % % clear srcVirChan1; %just memory issues
% % % clear srcVirChan2; %just memory issues
% % % 
% % % stat = ft_sourcestatistics(cfg, sourceTrials1,sourceTrials2);

%% Create stat map
for bandI = 1:length(bands)
    maskname = ['REST_MLR_T_values_', num2str(bands(bandI,1)) '_' num2str(bands(bandI,2))];
    make_partial_mask_with_values('C:\Users\Roey\Documents\MATLAB\Scripts\Michael_scripts\subfunctions\AAL_resliced_61x73x61_v2_michael.nii', 1:90, stat.stat(:,bandI), ['C:\Users\Roey\Documents\EEG_check_inverse\Results\' maskname '.nii'])
end


