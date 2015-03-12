function [freqStatistics] = freqAnalysisStatCluster(cfg,freq1,freq2)
% FreqAnalysis performs frequency analysis between conditions 
%
% INPUT
% cfg - the configurtion structure used by freqAnalysisWrap.
% freq1 & freq2 - files created by "query.m" (each containing one condition)
%
% OUTPUT
% freqStatistics - the statistics structures obtained from "ft_freqstatistics"
%
% Note: All trials are assumed to be the same length and the same fsample (same sampling rate)

%% Make sure both conditions have the same sampling rate
warning('Make sureboth conditions have the same sampling rate!');

%% Frequency Statistics
% as described in: http://fieldtrip.fcdonders.nl/tutorial/cluster_permutation_timelock
cfg = [];
cfg.design = [ ones(1,size(freq1(1).powspctrm ,1 ))  , 2*ones(1,size(freq2(1).powspctrm ,1 )) ]; % Use for two conditions
% cfg.design = [ ones(1,size(freq1(1).powspctrm ,1 ))  , ones(1,size(freq2(1).powspctrm ,1 )) ];
% cfg.design = [ ones(1,size(freq1(1).powspctrm ,1 ))  ]; % Use for one condition only
cfg.ivar = 1;
cfg.method =  'montecarlo'; %'stats'; OR 'Montecarlo';
cfg.parameter = 'powspctrm';
cfg.statistic = 'indepsamplesT';% or maybe 'depsamplesT' or 'indepsamplesT'
cfg.tail = 0; % -1, 0 or +1
cfg.alpha = 0.01;
cfg.clusteralpha = 0.01;
cfg.correctm = 'cluster';
cfg.numrandomization = 1000;
cfg.clusterstatistic = 'maxsum';

% Create neighbours
cfg_neighb = [];
cfg_neighb.method  = 'distance'; % CHECKME: consider using 'triangulation'
cfg_neighb.neighbourdist = 0.3; % since the sens is in units of dm. Default is 0.4
elecFile = which('elec1020.lay');
cfg_neighb.layout = elecFile;
cfg.neighbours  = ft_prepare_neighbours(cfg_neighb, freq1);

% Since the MCN system renames four points of the 10–20 system - T3, T4, T5
% and T6 - asT7, T8, P7 and P8 respectively, we must check to see if
% all electrodes were used. If not, we have to performthe following fix:
if (size(cfg.neighbours ,2) ~= size(freq1.label,2))
    freqTemp = freq1;
    freqTemp.label =  {'Fp1','Fp2','F7','F3','Fz','F4','F8','T7','C3','Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2'}; % Valid EEG labels in MCN format
    cfg_neighb.layout = elecFile;
    cfg.neighbours  = ft_prepare_neighbours(cfg_neighb, freqTemp);
    for elecI = 1:size(cfg.neighbours,2)
        if strcmp(cfg.neighbours(elecI).label, 'T7')
            cfg.neighbours(elecI).label = 'T3';
        elseif strcmp(cfg.neighbours(elecI).label, 'T8')    
            cfg.neighbours(elecI).label = 'T4';
        elseif strcmp(cfg.neighbours(elecI).label, 'P7')    
            cfg.neighbours(elecI).label = 'T5';
        elseif strcmp(cfg.neighbours(elecI).label, 'P8')
            cfg.neighbours(elecI).label = 'T6';
        end
        for neighI = 1:size(cfg.neighbours(elecI).neighblabel,1)
            if strcmp(cfg.neighbours(elecI).neighblabel{neighI}, 'T7')
                cfg.neighbours(elecI).neighblabel{neighI} = 'T3';
            elseif strcmp(cfg.neighbours(elecI).neighblabel{neighI}, 'T8')
                cfg.neighbours(elecI).neighblabel{neighI} = 'T4';
            elseif strcmp(cfg.neighbours(elecI).neighblabel{neighI}, 'P7')
                cfg.neighbours(elecI).neighblabel{neighI} = 'T5';
            elseif strcmp(cfg.neighbours(elecI).neighblabel{neighI}, 'P8')
                cfg.neighbours(elecI).neighblabel{neighI} = 'T6';
            end        
        end
                
    end
end % of fixing electrodes
freqStatistics = ft_freqstatistics(cfg, freq1, freq2);

% freqStatistics = ft_freqstatistics(cfg, freq1); % Use for one condition


end