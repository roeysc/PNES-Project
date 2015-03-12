function [freqN] = freqNorm (cfg, freq)
% freqNorm performs normalization of a frequency power spectrum on each trial
%
% INPUT
% freq - a frequency structure as created by freqAnalysisWrap: freq.powspctrm(trial x electrode x frequency_band)
% cfg.type - 'maxpertrial':   each trial normalized by the maximum power over all frequency bands
%                    - 'meanpertrial': each trial normalized by the mean power over all frequency bands
%                    - 'cordance': as explained in this article: http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2804067/#R39
%
% OUTPUT
% freqN - a normalized frequency structure according to the normalization type defined in cfg.type

trialsNum = size(freq.powspctrm,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (strcmp(cfg.type, 'maxpertrial'))
    for trialI = 1:trialsNum
        maxPow = max(squeeze(freq.powspctrm(trialI,:,:))')'; % maximum power (of band) in each electrode per trial
        maxPow = repmat(maxPow, 1, size(freq.powspctrm,3));
        maxPow = reshape(maxPow,1,size(maxPow,1),size(maxPow,2));
        freq.powspctrm(trialI,:,:) = freq.powspctrm(trialI,:,:)./maxPow;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (strcmp(cfg.type, 'maxpertrialoverbands'))
    for trialI = 1:trialsNum
        maxPow = max(squeeze(freq.powspctrm(trialI,:,:))')'; % maximum power (of band) in each electrode per trial
        maxPow = max(maxPow);
        freq.powspctrm(trialI,:,:) = freq.powspctrm(trialI,:,:)./maxPow;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (strcmp(cfg.type, 'meanpertrial'))
    for trialI = 1:trialsNum    
        meanPow = mean(squeeze(freq.powspctrm(trialI,:,:))')'; % mean power (over all bands) in each electrode per trial
        meanPow = repmat(meanPow, 1, size(freq.powspctrm,3));
        meanPow = reshape(meanPow,1,size(meanPow,1),size(meanPow,2));
        freq.powspctrm(trialI,:,:) = freq.powspctrm(trialI,:,:)./meanPow;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
end

freqN = freq;
end