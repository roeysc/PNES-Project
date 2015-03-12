function rawData = mat2rawdata(cfg, matData)
% mat2rawdata takes one mat file with data of one patient (as obtained from
% createDB_revised) and returns a fieldtrip compatible structure for
% preprocessing functions.
%
% cfg.continuous = 'yes' or 'no'; (contecanate all trials (and keep track
% of which is which using rawData.trialtype, or keep different trials. This only affects)
%
% e.g.: cfg=[]; cfg.continuous = 'no'; rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\DB\rereferenced\pRoey');

% TODO: do we want to write a header for our eeg records, simply to be read
% using ft_definetrial and ft_read_header? This could be better than simply
% adding another non-fieldtrip field like interpolatedElectrodes.

matData = load(matData);
conditions = fields(matData);

rawData = struct;
eval(['rawData.label = matData.' conditions{1} '.label'';']);
rawData.trial = [];
rawData.time = [];
rawData.sampleinfo = [];
eval(['rawData.fsample = matData.' conditions{1} '.fsample;']);
rawData.trialtype = []; % cell array containing the condition name of each trial 
rawData.interpolatedElectrodes = []; % these are actually the electrodes that need to be interpolated
rawData.trialStartTime = [];
rawData.trialinfo = [];

if strcmp(cfg.continuous, 'yes')    
    for conditionI = 1:length(conditions)
       eval(['matDataTemp = matData.' conditions{conditionI} ';']);
        for trialI = 1:length(matDataTemp.trial)
           % concatenate all trials 
           rawData.trial{1}(:, end+1:end+length(matDataTemp.trial{trialI})) = matDataTemp.trial{trialI};
           rawData.trialtype{end+1} = conditions{conditionI};
           rawData.interpolatedElectrodes{end+1} = matDataTemp.interpolatedElectrodes{trialI};
       end 
    end
    rawData.time{trialI} = 0 : 1/(rawData.fsample) : ((size(rawData.trial{trialI},2)-1)/(rawData.fsample));
    rawData.sampleinfo = [1, length(rawData.time{1})];
    rawData.trialStartTime = matData.startTime; 
    
else
    rawData.sampleinfo = [0 0]; % will be deleted later
    for conditionI = 1:length(conditions)
       eval(['matDataTemp = matData.' conditions{conditionI} ';']);
        for trialI = 1:length(matDataTemp.trial)
           % concatenate all trials 
           rawData.trial{end+1} = matDataTemp.trial{trialI};
           rawData.trialtype{end+1} = conditions{conditionI};
           rawData.interpolatedElectrodes{end+1} = matDataTemp.interpolatedElectrodes{trialI};
           rawData.time{end+1} = 0 : 1/(rawData.fsample) : ((size(rawData.trial{end},2)-1)/(rawData.fsample));
           rawData.sampleinfo(end+1,:) = [rawData.sampleinfo(end,2)+1, rawData.sampleinfo(end,2)+length(matDataTemp.trial{trialI})];
           rawData.trialinfo = [1:length(rawData.trial)]'; % this is the ordinal number of each trial
           rawData.trialStartTime{end+1} = matDataTemp.startTime{trialI}; 
        end 
    end
    rawData.sampleinfo(1,:) = [];
end

% Add a trialinfo field, holding the ordinal number of each trial


end
