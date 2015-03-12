function power_source = convert_time_source_to_power_source(time_source, band)
% convert_time_source_to_power_source converts a time domain source to
% power domain source around mean frequency in the specified band.
%
% Note: there are source reconstruction methods that give sources in the
% power domain. This function was created in order to check the validity of
% 'mne' as a time domain method for source reconstruction.
%
% TODO: the cfg is still like the time domain one, not the power one.

power_source = time_source;
power_source = rmfield(power_source, {'time', 'trial'});
power_source.freq = mean(band);

% Create "raw data" (label, time, trial) struct for use with ft_freqanalysis
raw_data = struct;
for labelI = 1:length(time_source.inside)
    raw_data.label{labelI} = num2str(labelI);
end
raw_data.trial = [];

for trialI = 1:length(time_source.trial)
    raw_data.trial{trialI} = time_source.trial(trialI).pow(time_source.inside,:);
    raw_data.time{trialI} = time_source.time;
end

% Transform to frequency domain
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmfft'; % why not mtmconvol?
cfg.taper        = 'hanning';
cfg.foi          = mean(band')';
cfg.keeptrials   = 'yes';

freqData= ft_freqanalysis(cfg, raw_data);

for trialI = 1:length(time_source.trial)
    power_source.trial(trialI) = struct('pow',freqData.powspctrm(trialI,:));
end



% A time source structure:
%     dim: [17 17 17]
%    time: [1x512 double]
%     pos: [4913x3 double]
%  inside: [1x2630 double]
% outside: [1x2283 double]
%  method: 'rawtrial'
%   trial: [1x22 struct]
%      df: 22
%     cfg: [1x1 struct]
%
% A power source structure:
%       dim: [17 17 17]
%      freq: 27
% cumtapcnt: [14x1 double]
%       pos: [4913x3 double]
%    inside: [1x2630 double]
%   outside: [1x2283 double]
%    method: 'rawtrial'
%     trial: [1x14 struct]
%             1x14 struct array with fields:
%                 pow
%        df: 14
%       cfg: [1x1 struct]
%
%
% Time source cfg field:
%               method: 'mne'
%                 elec: [1x1 struct]
%                 grid: [1x1 struct]
%                  vol: [1x1 struct]
%             rawtrial: 'yes'
%              hdmfile: 'C:\Users\Roey\Documents\EEG_PNES\MRI\realigned\segmented\headmodel\singlesphere_headmodel_spmTemplate.mat'
%                  mne: [1x1 struct]
%          singletrial: 'no'
%           keeptrials: 'yes'
%             callinfo: [1x1 struct]
%              version: [1x1 struct]
%          trackconfig: 'off'
%          checkconfig: 'loose'
%            checksize: 100000
%         showcallinfo: 'yes'
%                debug: 'no'
%        trackcallinfo: 'yes'
%        trackdatainfo: 'no'
%       trackparaminfo: 'no'
%              warning: [1x1 struct]
%        keepleadfield: 'no'
%          trialweight: 'equal'
%            jackknife: 'no'
%          pseudovalue: 'no'
%            bootstrap: 'no'
%        randomization: 'no'
%     numrandomization: 100
%          permutation: 'no'
%       numpermutation: 100
%             wakewulf: 'yes'
%             killwulf: 'yes'
%              channel: {19x1 cell}
%               supdip: []
%                order: 10
%              siunits: 'no'
%             previous: []
%
%
% Power source cfg fields:
%               method: 'dics'
%                 elec: [1x1 struct]
%                 grid: [1x1 struct]
%                  vol: [1x1 struct]
%             rawtrial: 'yes'
%              hdmfile: 'C:\Users\Roey\Documents\EEG_PNES\MRI\realigned\segmented\headmodel\singlesphere_headmodel_spmTemplate.mat'
%            frequency: 27
%          singletrial: 'no'
%           keeptrials: 'yes'
%             callinfo: [1x1 struct]
%              version: [1x1 struct]
%          trackconfig: 'off'
%          checkconfig: 'loose'
%            checksize: 100000
%         showcallinfo: 'yes'
%                debug: 'no'
%        trackcallinfo: 'yes'
%        trackdatainfo: 'no'
%       trackparaminfo: 'no'
%              warning: [1x1 struct]
%                 dics: [1x1 struct]
%        keepleadfield: 'no'
%          trialweight: 'equal'
%            jackknife: 'no'
%          pseudovalue: 'no'
%            bootstrap: 'no'
%        randomization: 'no'
%     numrandomization: 100
%          permutation: 'no'
%       numpermutation: 100
%             wakewulf: 'yes'
%             killwulf: 'yes'
%              channel: {19x1 cell}
%               supdip: []
%                order: 10
%              siunits: 'no'
%              dicsfix: 'yes'
%            quickflag: 0
%              refchan: []
%              latency: []
%             previous: [1x1 struct]