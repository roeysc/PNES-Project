function [freqCord1 freqCord2] = freqCordance(cfg, freqAbs1, freqRel1, freqAbs2, freqRel2)
% freqCordance returns the Absolute and Relative frequency structures of the condition
%
% INPUT
%
% OUTPUT
%

freqAbsAll= freqAbs1;
freqRelAll = freqRel1;

dim1 = size(freqAbsAll.powspctrm,1); % The number of trials in condition 1
freqAbsAll.powspctrm(dim1+1:dim1+size(freqAbs2.powspctrm,1), :, :) = freqAbs2.powspctrm(:,:,:);
freqRelAll.powspctrm(dim1+1:dim1+size(freqRel2.powspctrm,1), :, :) = freqRel2.powspctrm(:,:,:);

%% Find the mean over all segments
meanAbs = mean(freqAbsAll.powspctrm,1);
meanRel = mean(freqRelAll.powspctrm,1);

%% Find the STD overall segments
stdAbs = sqrt(var(freqAbsAll.powspctrm,1));
stdRel = sqrt(var(freqRelAll.powspctrm,1));

%% Perform normalization-standartization - Calculate z-scores
for segmentI = 1:size(freqAbs1.powspctrm,1)
    freqAbs1.powspctrm(segmentI,:,:) = (  freqAbs1.powspctrm(segmentI,:,:) - meanAbs  )  ./  stdAbs;
    freqRel1.powspctrm(segmentI,:,:) = (  freqRel1.powspctrm(segmentI,:,:) - meanRel  )  ./  stdRel;
end

for segmentI = 1:size(freqAbs2.powspctrm,1)
    freqAbs2.powspctrm(segmentI,:,:) = (  freqAbs2.powspctrm(segmentI,:,:) - meanAbs  )  ./  stdAbs;
    freqRel2.powspctrm(segmentI,:,:) = (  freqRel2.powspctrm(segmentI,:,:) - meanRel  )  ./  stdRel;
end

%% Add z-scores to calculate Cordance
freqCord1 = freqAbs1;
freqCord2 = freqAbs2;

freqCord1.powspctrm =[];
freqCord1.powspctrm = freqAbs1.powspctrm  + freqRel1.powspctrm;

freqCord2.powspctrm =[];
freqCord2.powspctrm = freqAbs2.powspctrm  + freqRel2.powspctrm;

end