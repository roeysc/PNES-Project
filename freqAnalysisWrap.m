function [ freq ] = freqAnalysisWrap ( cfg, input )
% FREQANALYSISWARP returns a frequency power spectrum of the signal in input file
%
% INPUT
% input - a  data file of the signal containing different trials in a format
%              obtained from "query.m" or "ft_preproccesing" OR an EEG signal struct.
% cfg - includes the following fields:
%           cfg.foilim: the frequency band of interest. e.g.:[4 8]
%           cfg.output: 'pow' (for frequency analysis) or 'powandcsd' (for source analysis, not supported by frequency analysis)
%           cfg.keeptrials: 'yes' or 'no'
%           cfg.analysistype: 'maxperlen' or 'smoothing'
%                                                    * 'maxperlen' means the analysis is performed at highest frequency resolution possible
%                                                       according to trials length: 1/length(in sec)
%                                                     * 'smoothing' means the analysis is performed around the center frequency in the band,
%                                                        with hanning taper
%                                                        window. Output format is freq.powspctrm(trial x electrode x frequency band)
% keepTrials - (OPTIONAL) if keepTrials = 'keepTrials', frequency analysis is done per trial.
%                            Otherwise, it is done on average over all  trials.
%                         
% OUTPUT
% freq - an array of frequency structures as obtained from "ft_freqanalysis".
%              Each i'th object in the array is the frequency analysis of the i'th frequency band

%% Check if input is file-path or struct
if ~isfield(cfg,'isfile')
    cfg.isfile = 'yes'; % The default is a file argument
end

%% Load file or Get struct
if (strcmp(cfg.isfile, 'yes'))
    file_content = load(input);
    FieldNames = fieldnames(file_content);
    conditionData = getfield(file_content,FieldNames{1}); 
    sRate = conditionData.fsample;
    trialLength = length( conditionData.trial{1} ) / sRate;

    data = [];
    data.trial = conditionData.trial;
    data.time = conditionData.time;
    data.fsample = conditionData.fsample;
    data.label= conditionData.label;
else % input is a struct, not a file
    data = input;   
end


%% Configure cfg
% calculate main frequency around which to perform analysis, and taper size
tmpcfg = [];
tmpcfg.channel = 'all';
tmpcfg.trials = 'all';
tmpcfg.output = cfg.output;% 'powandcsd' is used instead of 'pow' for source analysis purposes
tmpcfg.method = 'mtmfft';
tmpcfg.keeptrials = cfg.keeptrials;
tmpcfg.taper = 'hanning';

if strcmp(cfg.analysistype, 'smoothing')
    tmpcfg.foilim = [mean(cfg.foilim) mean(cfg.foilim)]; % perform analysis around the mean frequency in the "foilim" band

    % CHECKME: If trial time is less than 2 seconds, take floor of mean frequency
    % (otherwise ft_freqanalysis takes the ceiling)
    if size(data.time{1},2) < 2*data.fsample
        tmpcfg.foilim = floor(tmpcfg.foilim);
    end
    tmpcfg.tapsmofrq = cfg.foilim(end) - tmpcfg.foilim(end);

elseif strcmp(cfg.analysistype, 'maxperlen')
    tmpcfg.pad = cfg.analysistype; % this means the analysis will be performed in highest frequency resolution possible according to trials length: 1/length(in sec)
    tmpcfg.foilim = cfg.foilim;
else
    error('Undefined cfg.analysistype');
end

freq = ft_freqanalysis(tmpcfg,data);

end

