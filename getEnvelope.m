function [filteredData, envelopeData] = getEnvelope(cfg, data)
% getEnvelope computes the Band Limited Envelope of the raw data signal
%
% INPUT:
%               data: a raw data signal (as obtained with getSourceVirtualChannels for example)
%               cfg.foilim: frequencies of interest limits in Hz (i.e.: [4 8])  [could be 1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48]
%               cfg.
% OUTPUT:
%               filteredData: same as data, only filtered to the band specified in cfg.foilim
%               envelopeData: the envelope on the filtered data (for each trial and each ROI)
% NOTE:
%               if data contains NaN, no filtering will be done.
%               (that is why getSourceVirtualChannels gets rid of ROIs containing NaN)
%
% TODO: finish documentation
%
%   e.g.: cfg = []; cfg.foilim = [4 8];  [filteredData, envelopeData] = getEnvelope(cfg, srcVirChan);
%
% Based on:  http://fieldtrip.fcdonders.nl/example/crossfreq/phalow_amphigh#power_spectrum_of_amplitude_envelope_by_hilbert_transform

%% Filter data
filtercfg = [];
filtercfg.bpfilter = 'yes';
filtercfg.bpfreq = cfg.foilim;
% filtercfg.padding = 1; % TODO: what about the padding?
filteredData = ft_preprocessing(filtercfg, data);

%% Compute Envelopes
envelopeData = filteredData;

envcfg = [];
envcfg.bpfilter = 'yes';
envcfg.bpfreq  = cfg.foilim;
envcfg.hilbert = 'yes';
envcfg.keeptrials = 'yes';

% Each ROI needs to be computed seperately
for roiI = 1:length(envelopeData.label)    
    envcfg.channel = envelopeData.label{roiI};
    data_hilbert_in_ROI = ft_preprocessing(envcfg,envelopeData);
    
    for trialI = 1:length(envelopeData.trial)
        envelopeData.trial{trialI}(roiI,:) = data_hilbert_in_ROI.trial{trialI}(:,:);
    end
    
end

% TODO: we should check if this is the best envelope, maybe according to
% "BLP Method" article "Estimation of Instantaneous Power in the EEG to Assess Brain 
% Connectivity with High Temporal Resolution"
% See:
% roiI = 1;
% plot(filteredData.time{trialI},filteredData.trial{trialI}(roiI,:))
% hold on
% plot(envelopeData.time{trialI},envelopeData.trial{trialI}(roiI,:),'r', 'linewidth', 2)
end
