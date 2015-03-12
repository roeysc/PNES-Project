function dataOut = getTrials(cfg, dataIn)
% getTrials is used to get a data structure that only has specific trials
% in it. This is now used instead of calling fe_definetrial etc.
%
% INPUT
% cfg.trialtypes: cell array of the trial types to take from dataIn
% cfg.minlength: minimum length of trials to take (in seconds)
% cfg.maxlength: maximum length of trials to take (in seconds)
% cfg.segmenttrials: 'yes' or 'no' (segment long trials to trials of length maxlength)
%                    (default: 'no')
% cfg.trialindices: indices of wanted trials (optional)
%
% OUTPUT
% dataOut: a data structure similar to dataIn, only holding the trials
%          defined by cfg.trialtypes

% TODO: It could have been a good idea to get fields names from dataIm, so
% we could copy only relevant trials to dataOut to save some memory.
% However for the time being I decided against it for simplicity.


minlength = ft_getopt(cfg, 'minlength', 0);
maxlength = ft_getopt(cfg, 'maxlength', inf);
segmenttrials = ft_getopt(cfg, 'segmenttrials', 'no');
fsample = dataIn.fsample;

if isfield(cfg, 'trialindices')
    indices = cfg.trialindices;
else
    % First go over trial types, so that dataOut will have trials ordered by
    % types, in case several types are chosen in cfg.trialtypes
    indices = [];
    for trialTypeI = 1:length(cfg.trialtypes)
        for trialI = 1:length(dataIn.labfield.trialtype) 

            trialLength = length(dataIn.trial{trialI})/fsample;
            if(strcmp(dataIn.labfield.trialtype{trialI}, cfg.trialtypes{trialTypeI}) &&...
                      (trialLength >= minlength) &&...
                      ((trialLength <= maxlength) || strcmp(segmenttrials, 'yes')))
                    indices(end+1) = trialI;
            end

        end
    end
end

if strcmp(segmenttrials, 'no')
    dataOut = dataIn;
    dataOut.trial = dataOut.trial(indices);
    dataOut.time = dataOut.time(indices);
    dataOut.labfield.trialtype = dataOut.labfield.trialtype(indices);
    
    if isfield(dataOut, 'sampleinfo')
        dataOut.sampleinfo = dataOut.sampleinfo(indices,:);
    end
    if isfield(dataOut.labfield, 'interpolatedElectrodes')
        dataOut.labfield.interpolatedElectrodes = dataOut.labfield.interpolatedElectrodes(indices);
    end
    if isfield(dataOut.labfield, 'trialStartTime')
        dataOut.labfield.trialStartTime = dataOut.labfield.trialStartTime(indices);
    end
    
elseif strcmp(segmenttrials, 'yes')
    dataOut = [];
    if isfield(dataIn, 'elec')
        dataOut.elec = dataIn.elec;
    end
    dataOut.label = dataIn.label;
    dataOut.trial = {};
    dataOut.time= {};
    dataOut.sampleinfo = [];
    dataOut.labfield.trialtype = {};
    dataOut.labfield.interpolatedElectrodes = {};
    dataOut.labfield.trialStartTime = {}; 
    
    for trialI = 1:length(indices)
        trialLength = length(dataIn.trial{indices(trialI)})/dataIn.fsample;
        segmentsNum = 1;
        if trialLength >= maxlength
            segmentsNum = floor(trialLength/maxlength); % Number of possible segments in this trial
        end
        
        for segmentI = 1:segmentsNum 
            index = 1 + (segmentI-1)*maxlength*fsample; % index of first sample in segmentI
            
            dataOut.trial{end+1} = dataIn.trial{indices(trialI)}( :, index:index+maxlength*fsample-1 );
            dataOut.time{end+1} = 0 : 1/fsample : ((size(dataOut.trial{end},2)-1)/fsample);
            dataOut.labfield.trialtype(end+1) = dataIn.labfield.trialtype(indices(trialI));
            dataOut.labfield.trialStartTime{end+1} = dataIn.labfield.trialStartTime{indices(trialI)} + (segmentI-1)*length(dataOut.time{end})/(fsample*3600*24);
            
            
            if isfield(dataIn.labfield, 'interpolatedElectrodes')
                dataOut.labfield.interpolatedElectrodes(end+1) = dataIn.labfield.interpolatedElectrodes(indices(trialI));
            end
            if isfield(dataOut, 'sampleinfo')
                startSample = dataIn.sampleinfo(indices(trialI),1) + (1-segmentI)*maxlength*fsample;
                dataOut.sampleinfo(end+1,1) = startSample;
                dataOut.sampleinfo(end,2) = startSample + maxlength*fsample-1;
            end

        end
        
    end
end

end