function interpolatedData = interpolate_electrodes(cfg, data)
% interpolatedData gets a data structure obtained from rereference_and_filter
% and interpolates the electrodes in each trial seperately according to the
% interpolatedElectrodes
%
% INPUT
% cfg.elecFile (path to elc file, e.g. fullfile(which('standard_1020.elc'));
% cfg.layout (path to layout file, e.g. fullfile(which('EEG1020.lay'));
% cfg.plot = 'yes' or 'no' (plot the electrodes layout. default: yes)
%
% OUTPUT
% The same data as input, only with interpolated electrodes in each trial.


% Add the "elec" field to the data structre
% see http://fieldtrip.fcdonders.nl/faq/how_are_electrodes_magnetometers_or_gradiometers_described


% data.elec = elecCreate(data.label(1:21)); % TODO: this now applies to 19 electrodes only, not to the 64 cap
% The line above was used when we had to create elec with the lab electrode names, not the mcn.

data.elec = ft_read_sens(cfg.elecFile);
data.elec = reorder_electrodes(data.elec, data.label);
data.elec = ft_convert_units(data.elec, 'cm');

% Prepare structure of neighbouring electrodes
neicfg.method = 'distance';
neicfg.neighbourdist = 9; % maximum distance (in cm) between neighbouring electrodes
                           % recommended for 64 cap: 5.5
                           % recommended for 19 electrodes: 10

% neicfg.layout = cfg.layout;
neicfg.elec = data.elec;

intcfg.neighbours = ft_prepare_neighbours(neicfg);


% Plot neighbours
if strcmp(cfg.plot, 'yes')
    plotcfg = [];
    plotcfg.neighbours = intcfg.neighbours;
    ft_neighbourplot(plotcfg, data)
end
intcfg.method = 'nearest'; % replacs the electrode with the average of its neighbours weighted by distance

interpolatedData = data;
for trialI = 1:length(data.trial)

    intcfg.badchannel = data.labfield.interpolatedElectrodes{trialI}; % cell-array. see FT_CHANNELSELECTION for details
    intcfg.trials = trialI;
    interpolatedDataTemp = ft_channelrepair(intcfg, data); % cfg.lambda and cfg.order are set with default values
    interpolatedData.trial{trialI} = interpolatedDataTemp.trial{1};
    interpolatedDataTemp.time{trialI} = interpolatedDataTemp.time{1};
end

warning('FIX data.elec TO ALLOW USE OF 64 ELECTRODES!');
end



%%%%%%%%%%%%%%%%%%%%%    AUXILIARY FUNCTIONS    %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function elecNew = reorder_electrodes(elec, label)
% % reorder_electrodes redefines the order of the electrodes in the elec
% % struct to match that of the label (so it will be consistant with the data
% % itself).
% %
% % INPUT
% % elec: elec structre, as obtained from ft_read_sens
% % label: cell array of strings with electrode labels
% %
% % OUPUT
% % elecNew: the reordered elec structure
% 
% elecNew = elec;
% elecToSaveIndices = find(ismember(lower(elec.label), lower(label)));
% 
% elecNew.chanpos = elecNew.chanpos(elecToSaveIndices,:);
% elecNew.elecpos = elecNew.elecpos(elecToSaveIndices,:);
% elecNew.label = elecNew.label(elecToSaveIndices,:);
% 
% 
% end