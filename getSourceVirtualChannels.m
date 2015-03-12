function sourceVirtualChannels = getSourceVirtualChannels(cfg, source)
% getSourceVirtualChannels gets a source struct and creates a
% raw-data-like structure that can be used by subsequent fieldtrip
% functions.
% Specifically, it is used to turn a source reconstruction into
% atlas based virtual channels (each channel holds the signal of one source)
%
% INPUT:
%               source: a time-series source reconstruction obtained with ft_sourceanalysis
%               cfg.atlasPath: full path of atlas to be used (default: aal in fieldtrip)
%               cfg.chansel: cell array of selected channels (ROIs) to be used (default: 'all')
%
% OUTPUT:
%               sourceChannels: a struct similar to fieldtrip raw data (see FT_DATATYPE_RAW),
%               where each channel holds the time course of a certain ROI
%
% NOTE:  as always, cm are used and not mm.
%               if an ROI contains NaN in any of the trials, this ROI will be ommited from all trials
%
% TIP:
%               consider visualising using:
%               cfg = [];
%               cfg.viewmode = 'vertical';  % you can also specify 'butterfly'
%               ft_databrowser(cfg, sourceVirtualChannels);
%
%   e.g. (using default cfg):   srcVirChan = getSourceVirtualChannels([], sourceTrials)
%
% Based on:  http://fieldtrip.fcdonders.nl/tutorial/connectivity#extract_the_virtual_channel_time-series

%% Set default atlas path if necessary
if nargin<2
    error('Either cgf or source not given. Life is now a mess.');
end

if ~isfield(cfg, 'atlasPath')
    ftPath = which('ft_defaults');
    indices = find(ftPath == filesep);
    ftPath(indices(end)+1:end) = [];
    atlasPath = [ftPath 'template' filesep 'atlas' filesep 'aal' filesep 'ROI_MNI_V4.nii'];
    
    warning('AAL atlas will be used as default.')    
else
    atlasPath = cfg.atlasPath;
end

% Load atlas
atlas = ft_read_atlas(atlasPath);
atlas = ft_convert_units(atlas, 'cm');

% Change atlas to fieldtrip format if it is in spm format
if isfield(atlas, 'brick0')
    labels = load2struct(which('aal_labels.mat'))';
    atlas = spmAtlas2ftAtlas(atlas, labels);
end

%  Set default channels selection if necessary
if ~isfield(cfg, 'chansel')
    if isfield(atlas, 'tissuelabel')
        cfg.chansel = atlas.tissuelabel;
    else
        error('Atlas has no tissuelabel field. Consider giving cfg.chansel.');
    end
    warning('All ROIs will be used as default.')    
end
chansel = cfg.chansel;


%% Create the sourceVirtualChannels structure
sourceVirtualChannels = [];
sourceVirtualChannels.label = chansel;
% sourceVirtualChannels.time = source.time; % TODO: assuming all trials are the same length. Otherwise, we should consider gicing a time vector for wach trial, if this is what is done in raw data structure.

% Find ROIs masks and average over them
tmpcfg = [];
tmpcfg.atlas = atlas;
tmpcfg.coordsys = 'mni';
tmpcfg.inputcoord = 'mni';
data_for_ROI_masks = source;
data_for_ROI_masks.pow = data_for_ROI_masks.trial(1).pow; % only the first trial is (arbitrarily) used to find the right indices or each ROI mask

for roiI = 1:length(chansel)
    tmpcfg.roi = chansel{roiI};
    % Create a logical mask of the ROI
    roi_mask = ft_volumelookup(tmpcfg,data_for_ROI_masks); % TODO: DOES IT REALLY GIVE CORRECT VOXELS?
    roi_mask(data_for_ROI_masks.outside) = 0; % Discard nodes outside grey matter
    
    for trialI = 1:length(source.trial)
        sourceVirtualChannels.time{1,trialI} = source.time;
        mean_TC_in_ROI = mean(source.trial(trialI).pow(roi_mask(:), :)); % the mean time course in the ROI in trialI        
        sourceVirtualChannels.trial{trialI}(roiI,:) = mean_TC_in_ROI;
    end
end

%% Check if there are NaNs in the data, and if so delete them
% otherwise no filtering is possible later on (e.g. using ft_preprocessing in getBLP)
for trialI = 1:length(source.trial)
    if any(isnan(   sourceVirtualChannels.trial{trialI} ))
        nanROIs = find(isnan(sourceVirtualChannels.trial{trialI}(:,1)))
        % delete the NaN channel from labels list
        sourceVirtualChannels.label(nanROIs) = [];
        warning(['ROIs ' chansel{nanROIs} ' contain NaN, and will be ommited from all trials!']);
        for trialI = 1:length(source.trial)
            sourceVirtualChannels.trial{trialI} = sourceVirtualChannels.trial{trialI}(  ~ismember(1:size(sourceVirtualChannels.trial{trialI},1), nanROIs) ,:); % this deletes bad rows, like in: a=magic(5); b = a(~ismember(1:size(a,1), [2,3]) , :)
        end
    end
end
            
            
end

% TODO: it seems like some of the nodes are not included in any ROI. This
% might be due to nodes that aren't grey matter, and we should check this.
% Likewise, some ROIs dont contain any nodes. This could be because of our
% spatial resolution, and we might want to use a less fine atlas.