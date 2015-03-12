function [ freqBands ] = freqAnalysisWarp ( file, bands, keepTrials, meanBands)
% FREQANALYSISWARP returns a frequency power spectrum of the signal in input file
%
% INPUT
% file - a  data file of the signal containing different trials in a format
%              obtained from "Query.m" or "ft_preproccesing".
% bands - (OPTIONAL) a matrix of the freequency bands used in the analysis. e.g: [1 4 ; 4 8 ; 8 13 ; 13 30]
%               if band is EMPTY, default bands are assumed: [0 4 ; 4 8 ; 8 13 ; 13 16 ; 16 30 ; 30  100 ]
% keepTrials - (OPTIONAL) if keepTrials = 'keepTrials', frequency analysis is done per trial.
%                            Otherwise, it is done on average over all  trials.
% meanBands- (OPTIONAL) if meanBands= 'meanBands', frequency analysis is averaged over all
%                         frequencies in each band.
%                         
% OUTPUT
% freq - an array of frequency structures as obtained from "ft_freqanalysis".
%              Each i'th object in the array is the frequency analysis of the i'th frequency band
%
% e.g.:  freq1 =   freqAnalysisWarp(file1, [], 'keepTrials', 'no'); 
% e.g.:  freq2 =   freqAnalysisWarp(file2, [], 'keepTrials', 'meanBands');
%% Load file and Configure cfg
file_content = load(file);
FieldNames = fieldnames(file_content);
conditionData = getfield(file_content,FieldNames{1}); 
sRate = conditionData.fsample;
trialLength = length( conditionData.trial{1} ) / sRate;

data = [];
data.trial = conditionData.trial;
data.time = conditionData.time;
data.fsample = conditionData.fsample;
data.label= conditionData.label;

cfg = [];
cfg.channel = 'EEG';
cfg.trials = 'all';
cfg.output = 'pow';
cfg.method = 'mtmfft';
cfg.taper = 'hanning' ;
cfg.pad = 'maxperlen'; % this means the analysis will be performed in highest frequenct resolution possible according to trials length: 1/length(in sec)

% cfg.t_ftimwin = 4 ./ cfg.foi; % consider using cfg.foi instead. ###################### Consider changing 4
% cfg.tapsmofrq = 
% cfg.t_ftimwin = 4 / cfg.foilim(end);

% cfg.toi = -0.5:0.2:trialLength;
% cfg.channel = 'all';

if isempty(bands)
    bands = [ 0 4 ; 4 8 ; 8 13 ; 13 16 ; 16 30 ; 30  100 ];
end

if strcmp(keepTrials, 'keepTrials')
    cfg.keeptrials = 'yes';
end

% right now the frequency analysis is done in the highest resolution
% possible and then averaged over each band
if strcmp(meanBands, 'meanBands') 
    cfg.foilim = [ bands(1) bands(end) ]; % The overall band of interest, will be divided later
    freq = ft_freqanalysis(cfg,data);

    freqBands = freq; % Make sure the output freqBands is in the correct format
    freqBands.freq = 1:size(bands,1);

    for freqBandI = 1:size(bands,1)
        indexBegin = find(freq.freq >= bands(freqBandI,1));
        indexBegin = indexBegin (1);
        indexEnd = find(freq.freq <= bands(freqBandI,2));
        indexEnd = indexEnd(end);
        freqBands.powspctrm(:,:,freqBandI) = mean(  freq.powspctrm(:,:,indexBegin:indexEnd), 3);
    end
    freqBands.powspctrm(:,:,freqBandI+1:end) = [];

else % if frequency analysis is not divided into bands

    cfg.foilim = [ bands(1) bands(end)];
    freq = ft_freqanalysis(cfg,data);
    freqBands = freq; % True, this is not divided into bands, but this is the default output name for this function.
end

end

