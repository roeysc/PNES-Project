function [ sourceCondition1, sourceCondition2 ] = sourceAnalysisWrap( cfg, segmentedMRI, queryFile1, queryFile2 )
% SOURCEANALYSISWARP performs source analysis between conditions 
%
% INPUT
% cfg - the configurtion structure used by freqAnalysisWrap.
% segmentedMRI - full path of patient's segmented MRI file (as obtained from segmentMRI.mat)
% queryFile1,2 - full path of two data files of two conditions (as obtained from query.mat)
%
% OUTPUT
% sourceCondition1, sourceCondition2
%
% NOTE: THIS VERSION OF SOURCEANALYSISWARP USES A FILTER FOR EACH TRIAL SEPERATLY

%% create temporary DIR to be used later
tempDir = segmentedMRI;
index = find(tempDir == '\');
tempDir(index(end)+1 : end) = [];

%% Prepare Head Model
segmentedMriFile = segmentedMRI;
data = load(segmentedMRI);
segmentedMRI = data.tpm_segmentedmri; % in  mm
segmentedMRI = ft_convert_units(segmentedMRI,'cm'); % Convert to cm
clear data;

tmpcfg = [];
tmpcfg.method = 'singlesphere'; %%% What does that mean? Do we have other preferable models?
vol = ft_prepare_headmodel(tmpcfg, segmentedMRI); % same units as segmentedMRI (cm)

warning('Make sure data is in Average Reference before frequency analysis is done!');

%% Compute lead field

% Load Patient's Electrode File
elecFileName = dir(segmentedMriFile);
elecFileName = ['elec_', elecFileName.name];
elecFileDir = segmentedMriFile;
slashIndices = find(elecFileDir=='\');
elecFileDir = elecFileDir(1:slashIndices(end));
elecFileDir = [elecFileDir, elecFileName];

elec = load(elecFileDir); % in mm, in the MNI coordinate system
elec = elec.elecTemp;
elec = ft_convert_units(elec,'cm'); % Convert to cm

%% Prepare Leadfield
tmpcfg = [];
tmpcfg.elec = elec;
tmpcfg.vol = vol;
tmpcfg.reducerank = 3; % 3 is the default for EEG (and 2 is the default for MEG)
tmpcfg.channel = {'EEG'};
tmpcfg.grid.resolution = 1;   % use a 3D grid with a 1 cm resolution
[grid] = ft_prepare_leadfield(tmpcfg);

%% Perform Source Anslysis on both condition
% Perform frequency analysis of combines conditions for the common filter
condition1 = load(queryFile1);
        condition1 = condition1 .data;
condition2 = load(queryFile2);
        condition2 = condition2.data;

% Frequency Analysis
freqCondition1= freqAnalysisWrap(cfg, queryFile1);
freqCondition2= freqAnalysisWrap(cfg, queryFile2);

% Calculate Spatial Filter for each condition
cfg=[];
cfg.method  = 'dics';
cfg.elec = elec;
cfg.grid = grid;
cfg.vol = vol;
cfg.frequency = freqCondition1.freq; % We do not calculate the mean of foilim here in case some rounding was done in freqAnalysisWrap
cfg.rawtrial  = 'yes'; % cfg.keepfilter  = 'yes';
% % %  change back the above line and fix line 260 in ft_sourceanalysis

sourceCondition1 = ft_sourceanalysis(cfg, freqCondition1); 
sourceCondition2 = ft_sourceanalysis(cfg, freqCondition2);

% % % % Project each trial throught the Spatial Filter calculated above
% % % cfg=[];
% % % cfg.method  = 'dics';
% % % cfg.elec = elec;
% % % cfg.grid = grid;
% % % cfg.vol = vol;
% % % cfg.frequency = freqCondition1.freq; % We do not claculate the mean of foilim here in case some rounding was done in freqAnalysisWrap
% % % cfg.rawtrial  = 'yes';
% % % 
% % % cfg.grid.filter = sourceCondition1.avg.filter; % use the spatial filter computed in the previous step
% % % sourceCondition1 = ft_sourceanalysis(cfg, freqCondition1); 
% % % 
% % % cfg.grid.filter = sourceCondition2.avg.filter; % use the spatial filter computed in the previous step
% % % sourceCondition2 = ft_sourceanalysis(cfg, freqCondition2);




%% 
% The following code was used when we thought we could use a common filter.

% % % %% Create Common Spatial Filter  and  Perform Source Anslysis
% % % % Perform frequency analysis of combines conditions for the common filter
% % % condition1 = load(queryFile1);
% % %         condition1 = condition1 .data;
% % % condition2 = load(queryFile2);
% % %         condition2 = condition2.data;
% % % combinedConditions = ft_appenddata([], condition1, condition2);
% % % 
% % % save([tempDir, 'combinedConditionsQuery.mat'], 'combinedConditions');
% % % 
% % % % Compute common spatial filter
% % % freqCombined = freqAnalysisWarp([tempDir, 'combinedConditionsQuery.mat'] , [], 'keepTrials', 'no', 'powandcsd'); % DO WE WANT ANALYSIS ON A SPECIFIC FREQUENCY?
% % % 
% % % delete([tempDir, 'combinedConditionsQuery.mat']);
% % % 
% % % cfg=[];
% % % cfg.method  = 'dics';
% % % cfg.elec = elec;
% % % cfg.grid = grid;
% % % cfg.vol = vol;
% % % cfg.frequency = 9; % WHAT FREQUENCIES DO WE WANT TO USE? DO WE WANT THEM IN A LOOP?
% % % cfg.keepfilter  = 'yes';
% % % 
% % % sourceCombined = ft_sourceanalysis(cfg, freqCombined);
% % % 
% % % 
% % % % project all trials through common spatial filter
% % % cfg=[];
% % % cfg.method  = 'dics';
% % % cfg.elec = elec;
% % % cfg.grid = grid;
% % % cfg.vol = vol;
% % % cfg.grid.filter = sourceCombined.avg.filter; % use the common filter computed in the previous step
% % % cfg.frequency = 9; % WHAT FREQUENCIES DO WE WANT TO USE? DO WE WANT THEM IN A LOOP?
% % % cfg.rawtrial = 'yes'; % project each single trial through the filter
% % % 
% % % freqCondition1= freqAnalysisWarp(queryFile1 , [], 'keepTrials', 'no','powandcsd'); % DO WE WANT ANALYSIS ON A SPECIFIC FREQUENCY?
% % % freqCondition2= freqAnalysisWarp(queryFile2 , [], 'keepTrials', 'no','powandcsd'); % DO WE WANT ANALYSIS ON A SPECIFIC FREQUENCY?
% % % 
% % % % Source Analysis
% % % sourceCondition1 = ft_sourceanalysis(cfg, freqCondition1); 
% % % sourceCondition2 = ft_sourceanalysis(cfg, freqCondition2);
% % % sourceCombined = ft_sourceanalysis(cfg, freqCombined); % Recreate sourceCombined using the common filter
% % % 
% % % %% Get the AVERAGE POWER SPECTRUM from all trials
% % % warning('* * * AVERAGE * * *  POWER SPECTRUM FOR BOTH CONDITIONS WILL BE CALCULATED');
% % % 
% % % trialsNum1 = size(sourceCondition1.trial,2);
% % %  temp = zeros(size(sourceCondition1.trial(1).pow));
% % %  for trialI = 1:trialsNum1
% % %      temp = temp + sourceCondition1.trial(trialI).pow;
% % %  end
% % %  avgPowCondition1 = temp ./ trialsNum1;
% % %  
% % %  trialsNum2= size(sourceCondition2.trial,2);
% % %  temp = zeros(size(sourceCondition2.trial(1).pow));
% % %  for trialI = 1:trialsNum2
% % %      temp = temp + sourceCondition2.trial(trialI).pow;
% % %  end
% % %  avgPowCondition2 = temp ./ trialsNum2;
% % %  
% % %  sourceCondition1.avg.pow = avgPowCondition1; % THIS COULD BE PROBLEMATIC SINCE OTHER PARAMETERS ARE INVOLVED IN sourceCondition1
% % %  sourceCondition2.avg.pow = avgPowCondition2; % THIS COULD BE PROBLEMATIC SINCE OTHER PARAMETERS ARE INVOLVED IN sourceCondition2