% EEG bad electrode repair
% requires fieldtrip
%
% input format:
% labels   - 1XN cell array  
% badchans - 1XB cell array eg. {'O2', 'Fp2'}
% data     - MXN array

function fixedelec = fixelec(data, labels, badchans)

error(nargchk(3, 3, nargin));

% transpose data to lab style
data = data';
badchans = badchans';

eeglabels = {'Fp1','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','O2'};    

% generating neighbours map (only locations are needed for spline)
[s,elec.elecpos] = elec_1020select(eeglabels);
elec.label = eeglabels;
elec.chanpos = elec.elecpos;
elec.tra = eye(length(eeglabels));
cfg.method = 'triangulation';
cfg.elec = elec;
ndata = data;
ndata.label = eeglabels;
neighbours = ft_prepare_neighbours(cfg, ndata);

% converting data to proper format
l = length(data);
for i=1:length(eeglabels)
    trial(i,:) = data(find(cell2mat(cellfun(@ (x) strcmp(x,eeglabels(i)),labels,'UniformOutput',0))),:);
end
data.trial = {trial};
data.elec = elec;
data.label = eeglabels;
data.time = {[1:l]};

% fixing bad channels
cfg = [];
cfg.method = 'spline';
cfg.badchannel = badchans;
cfg.neighbours = neighbours;
repaired = ft_channelrepair(cfg, data);
fixedelec = cell2mat(repaired.trial);