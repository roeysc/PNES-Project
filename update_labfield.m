function newData = update_labfield (cfg, newData, oldData)
% update_labfield adds the field "labfield" to the newData structure,
% according to the labfield structure in oldData.
%
% This is usefull for cases like cutting smaller trials from an original
% data structure (either by hand, or using ft_rejectartifact, like in our 
% preprocessing_pipeline code).
%
% cfg.ordinalIndicesColumn: the column in newData.trialinfo that holds the
%                           ordinal indexing of each trial.
%
% The following subfields are now supported:
%                  trialtype: {1xN cell}
%     interpolatedElectrodes: {1xN cell}
%             trialStartTime: {1xN cell}
% NOTE: when new fields are added to labfield in the future, this function
% will have to be updated as well.
%
% NOTE: newData.trialinfo is assumed to be the ordinal indexing of the
% trials.

indices = newData.trialinfo(:, cfg.ordinalIndicesColumn );

newData.labfield.trialtype = oldData.labfield.trialtype(indices);
newData.labfield.interpolatedElectrodes = oldData.labfield.interpolatedElectrodes(indices);

% trialStartTime needs to be updated for each trial that was cut from an
% older trial
newData.labfield.trialStartTime = oldData.labfield.trialStartTime(indices);

a = diff(indices);
trialsToUpdate = find(a == 0) + 1;

for i = 1:length(trialsToUpdate)
    
    if ( (i == 1) || ~(trialsToUpdate(i)-trialsToUpdate(i-1)) == 0 )
        originalTrialIndex = trialsToUpdate(i) - 1;
    end
    
    samplesDiff = newData.sampleinfo(trialsToUpdate(i),1) - newData.sampleinfo(originalTrialIndex,1); % the number of samples between start of trial i and start the original trial
    newData.labfield.trialStartTime{trialsToUpdate(i)} = newData.labfield.trialStartTime{originalTrialIndex} + samplesDiff/(newData.fsample*3600*24);
    
end

end