% EEG bad electrode repair
% requires fieldtrip
%
% input format:
% labels   - 1XN cell array  
% badchans - 1XB cell array eg. {'O2', 'Fp2'}
% data     - MXN array

function fixedelec = fixelecByDist(data, labels, badchans)

error(nargchk(3, 3, nargin));

% transpose data to lab style
data = data';
badchans = badchans';

eeglabels = labels;

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

% We chose to change the neighbours struct to fit the way neighbours are chosen in other codes
% such as "createDB", "freqAbsRel" and "freqStat..." (Aia & Roey, 18.09.2013)

cfg_neighb = [];
cfg_neighb.method  = 'distance'; % CHECKME: consider using 'triangulation'
cfg_neighb.neighbourdist = 0.3; % since the sens is in units of dm. Default is 0.4
elecFile = which('elec1020.lay');
cfg_neighb.layout = elecFile;

dataTemp1 = [];
dataTemp1.label = eeglabels;
neighbours  = ft_prepare_neighbours(cfg_neighb, dataTemp1);


% Since the MCN system renames four points of the 10–20 system—T3, T4, T5
% and T6—asT7, T8, P7 and P8 respectively, we must check to see if
% all electrodes were used. If not, we have to performthe following fix:
if (size(neighbours ,2) ~= size(dataTemp1.label,2))
    dataTemp = dataTemp1;
    dataTemp.label =  {'Fp1','Fp2','F7','F3','Fz','F4','F8','T7','C3','Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2'}; % Valid EEG labels in MCN format
    cfg_neighb.layout = elecFile;
    neighbours  = ft_prepare_neighbours(cfg_neighb, dataTemp);
    for elecI = 1:size(neighbours,2)
        if strcmp(neighbours(elecI).label, 'T7')
            neighbours(elecI).label = 'T3';
        elseif strcmp(neighbours(elecI).label, 'T8')    
            neighbours(elecI).label = 'T4';
        elseif strcmp(neighbours(elecI).label, 'P7')    
            neighbours(elecI).label = 'T5';
        elseif strcmp(neighbours(elecI).label, 'P8')
            neighbours(elecI).label = 'T6';
        end
        for neighI = 1:size(neighbours(elecI).neighblabel,1)
            if strcmp(neighbours(elecI).neighblabel{neighI}, 'T7')
                neighbours(elecI).neighblabel{neighI} = 'T3';
            elseif strcmp(neighbours(elecI).neighblabel{neighI}, 'T8')
                neighbours(elecI).neighblabel{neighI} = 'T4';
            elseif strcmp(neighbours(elecI).neighblabel{neighI}, 'P7')
                neighbours(elecI).neighblabel{neighI} = 'T5';
            elseif strcmp(neighbours(elecI).neighblabel{neighI}, 'P8')
                neighbours(elecI).neighblabel{neighI} = 'T6';
            end        
        end
                
    end
end % of fixing electrodes
neighbours = neighbours';

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