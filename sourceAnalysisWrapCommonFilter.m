function [ sourceCondition1, sourceCondition2 ] = sourceAnalysisWrapCommonFilter( cfg, segmentedMRI, queryFile1, queryFile2 )
% SOURCEANALYSISWARP performs source analysis between conditions 
%
% INPUT
% cfg - the configurtion structure used by freqAnalysisWrap.
% segmentedMRI - full path of patient's segmented MRI file (as obtained from segmentMRI.mat)
% queryFile1,2 - full path of two data files of two conditions (as obtained from query.mat)
%
% OUTPUT
% sourceCondition1, sourceCondition2

%% create temporary DIR to be used later
tempDir = segmentedMRI;
index = find(tempDir == '\');
patientName = tempDir(index(end)+1:end);
    patientName = patientName(15:end-4);
tempDir(index(end)+1 : end) = [];
segmentedMriFile = segmentedMRI;

%% All this part was moves to a new code named "createMeshBasedHeadmodel"
% % % % % % % % %% Load Segmented MRI File
% % % % % % % % 
% % % % % % % % segmentedMriFile = segmentedMRI;
% % % % % % % % data = load(segmentedMRI);
% % % % % % % % segmentedMRI = data.bss_segmentedmri; % in  mm  %% CHECKME: This should be more genera, so we can switch between tpm and bss
% % % % % % % % segmentedMRI = ft_convert_units(segmentedMRI,'cm'); % Convert to cm
% % % % % % % % clear data;
% % % % % % % %                 %     21.01.2014    % I try using a 3 layer mesh instead of the  segmented MRI
% % % % % % % %                 meshcfg.method = 'iso2mesh';
% % % % % % % %                 meshcfg.numvertices = 10000;   % We'll decimate later - this gives nicer results
% % % % % % % %                 meshcfg.tissue={'brain','skull','scalp'};
% % % % % % % %                 bnd = ft_prepare_mesh(meshcfg,segmentedMRI);
% % % % % % % % 
% % % % % % % %                 % Decimate to a 1000, 2000, 3000 node mesh (scalp, skull, brain)
% % % % % % % %                 [bnd(1).pnt, bnd(1).tri] = meshresample(bnd(1).pnt, bnd(1).tri, 1000/size(bnd(1).pnt,1));
% % % % % % % %                 [bnd(2).pnt, bnd(2).tri] = meshresample(bnd(2).pnt, bnd(2).tri, 2000/size(bnd(2).pnt,1));
% % % % % % % %                 [bnd(3).pnt, bnd(3).tri] = meshresample(bnd(3).pnt, bnd(3).tri, 3000/size(bnd(3).pnt,1));
% % % % % % % %                 
% % % % % % % %                 % Fix meshes intersections
% % % % % % % %                 decouplesurf(bnd);                
% % % % % % % %                 % Fix meshes self-intersections using the iso2mesh toolbox
% % % % % % % %                 % (available in fieldtrip's full version)
% % % % % % % %                 [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'dup');
% % % % % % % %                 [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'isolated');
% % % % % % % %                 [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'deep');
% % % % % % % %                 [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'meshfix');
% % % % % % % %                 
% % % % % % % %                 % Plot meshes to check
% % % % % % % %                 figure; ft_plot_mesh(bnd(1));
% % % % % % % %                 figure; ft_plot_mesh(bnd(2));
% % % % % % % %                 figure; ft_plot_mesh(bnd(3));
% % % % % % % % 
% % % % % % % % %% Prepare Head Model
% % % % % % % % tmpcfg = [];
% % % % % % % % tmpcfg.method = cfg.method; %%% What does that mean? Do we have other preferable models?
% % % % % % % % vol = ft_prepare_headmodel(tmpcfg, segmentedMRI); % same units as segmentedMRI (cm)
% % % % % % % % vol = ft_convert_units(vol,'cm');

warning('Make sure data is in Average Reference before frequency analysis is done!');

% Load Patient's Electrode File
elecFileName = ['elec_', patientName '.mat'];
elecFileDir = segmentedMriFile;
slashIndices = find(elecFileDir=='\');
elecFileDir = elecFileDir(1:slashIndices(end));
elecFileDir = [elecFileDir, elecFileName];

elec = load(elecFileDir); % in mm, in the MNI coordinate system
elec = elec.elecTemp;
elec = ft_convert_units(elec,'cm'); % Convert to cm

%% Compute lead field
% THE FOLLOWING LINES WERE USED WHEN "GRID" WAS CALCULATED HERE. BUT NOW WE
% CRATE THE GRID BEFOREHAND USING createSubjectMNIGRID.
% 
% tmpcfg = [];
% tmpcfg.elec = elec;
% tmpcfg.vol = vol; % vol is the headmodel we created previously in the method we defined
% tmpcfg.reducerank = 3; % 3 is the default for EEG (and 2 is the default for MEG)
% tmpcfg.channel = {'EEG'};
% tmpcfg.grid.resolution = 1;   % use a 3D grid with a 1 cm resolution
% [grid] = ft_prepare_leadfield(tmpcfg);
grid = load([tempDir 'grids\grid_' cfg.method '_', patientName]);
    grid = grid.grid;
    
%% Load the patient's headmodel (vol)
load([tempDir, 'headmodel\openmeeg_headmodel_' patientName '.mat']); % this loads the headmodel in a structure called "vol"

%% Create Common Spatial Filter  and  Perform Source Anslysis
% Perform frequency analysis of combines conditions for the common filter
condition1 = load(queryFile1);
        condition1 = condition1 .data;
condition2 = load(queryFile2);
        condition2 = condition2.data;
combinedConditions = ft_appenddata([], condition1, condition2);

save([tempDir, 'combinedConditionsQuery.mat'], 'combinedConditions');

% Compute common spatial filter
freqCombined = freqAnalysisWrap(cfg, [tempDir, 'combinedConditionsQuery.mat']); % DO WE WANT ANALYSIS ON A SPECIFIC FREQUENCY?
% freqCondition1,2 are claculated here because they use the same cfg:
freqCondition1 = freqAnalysisWrap(cfg, queryFile1); % DO WE WANT ANALYSIS ON A SPECIFIC FREQUENCY?
freqCondition2 = freqAnalysisWrap(cfg, queryFile2); % DO WE WANT ANALYSIS ON A SPECIFIC FREQUENCY?


delete([tempDir, 'combinedConditionsQuery.mat']);

cfg=[];
cfg.method  = 'dics';
cfg.elec = elec;
cfg.grid = grid;
cfg.vol = vol;
cfg.frequency = freqCondition1.freq; % The mean frequency in the band
cfg.keepfilter  = 'yes';

sourceCombined = ft_sourceanalysis(cfg, freqCombined);

% project all trials through common spatial filter
cfg=[];
cfg.method  = 'dics';
cfg.elec = elec;
cfg.grid = grid; % This is the patient's grid
cfg.vol = vol;
cfg.grid.filter = sourceCombined.avg.filter; % use the common filter computed in the previous step
cfg.frequency = freqCondition2.freq; % The mean frequency in the band
cfg.rawtrial = 'yes'; % project each single trial through the filter


% Source Analysis
sourceCondition1 = ft_sourceanalysis(cfg, freqCondition1); 
sourceCondition2 = ft_sourceanalysis(cfg, freqCondition2);
sourceCombined = ft_sourceanalysis(cfg, freqCombined); % Recreate sourceCombined using the common filter

%% Get the AVERAGE POWER SPECTRUM from all trials
warning('* * * AVERAGE * * *  POWER SPECTRUM FOR BOTH CONDITIONS WILL BE CALCULATED');

trialsNum1 = size(sourceCondition1.trial,2);
 temp = zeros(size(sourceCondition1.trial(1).pow));
 for trialI = 1:trialsNum1
     temp = temp + sourceCondition1.trial(trialI).pow;
 end
 avgPowCondition1 = temp ./ trialsNum1;
 
 trialsNum2= size(sourceCondition2.trial,2);
 temp = zeros(size(sourceCondition2.trial(1).pow));
 for trialI = 1:trialsNum2
     temp = temp + sourceCondition2.trial(trialI).pow;
 end
 avgPowCondition2 = temp ./ trialsNum2;
 
 sourceCondition1.avg.pow = avgPowCondition1; % THIS COULD BE PROBLEMATIC SINCE OTHER PARAMETERS ARE INVOLVED IN sourceCondition1
 sourceCondition2.avg.pow = avgPowCondition2; % THIS COULD BE PROBLEMATIC SINCE OTHER PARAMETERS ARE INVOLVED IN sourceCondition2