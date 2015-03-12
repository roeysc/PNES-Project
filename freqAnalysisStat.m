function [freqStatistics] = freqAnalysisStat(file1,file2)
% FreqAnalysis performs frequency analysis between conditions 
%
% INPUT
% file1 & file2 are files created by "query.m" (each containing one condition)
%
% OUTPUT
% freqStatistics - the statistics structures obtained from "ft_freqstatistics"
%
% Note: All trials are assumed to be the same length and the same fsample (same sampling rate)

%% Standartize the Segments -  ##################################################################################################################
warning('standartization');

%% Make sure all trials are the same length and have the same sampling rate
file1_content = load(file1);
file2_content = load(file1);

if (file1_content.data.fsample ~= file2_content.data.fsample)
    error('Files do not have the same sampling rate!');
end
if (file1_content.data.time{1}(end) ~= file2_content.data.time{1}(end))
    error('Trials in both files are not the same length!');
end

%% Frequency Analysis of file1 and file2
freq1 = freqAnalysisWarp(file1, [1 4; 4 8; 8 9 ; 9 12; 12 16;16 20; 20 30; 30 48], 'keepTrials', 'meanBands','pow');
freq2 = freqAnalysisWarp(file2, [1 4; 4 8; 8 9; 9 12; 12 16;16 20; 20 30; 30 48], 'keepTrials', 'meanBands','pow');

%% Frequency Statistics
% cfg. design = [ones(1,trialsNumber1), 2*ones(1,trialsNumber2)];
% cfg.dataset = conditiontrials;
% cfg.inputfile = conditiontrials; 
% cfg.trials = conditiontrials;

% consider using cfg.avgovertime = 'yes'; OR cfg.avgoverfreq OR  = 'yes'; % OR cfg.avgoverchan = 'yes'

cfg = [];
cfg.design = [ ones(1,size(freq1(1).powspctrm ,1 ))  , 2*ones(1,size(freq2(1).powspctrm ,1 )) ]; % Use for two conditions
% cfg.design = [ ones(1,size(freq1(1).powspctrm ,1 ))  , ones(1,size(freq2(1).powspctrm ,1 )) ];
% cfg.design = [ ones(1,size(freq1(1).powspctrm ,1 ))  ]; % Use for one condition only

cfg.ivar = 1;
cfg.method =  'stats'; %'stats'; OR 'Montecarlo';
cfg.statistic = 'ttest2';%'anova1'; % 'ttest2';
cfg.tail = 0; % -1, 0 or +1
cfg.alpha = 0.01;

freqStatistics = ft_freqstatistics(cfg, freq1, freq2);
% freqStatistics = ft_freqstatistics(cfg, freq1); % Use for one condition


end