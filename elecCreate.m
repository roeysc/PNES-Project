function elec = elecCreate( validEEGLabels )
% elecCreate creates an elec structure used by FieldTrip in source reconstruction etc.
%
% INPUT
% validEEGLabels - the electrode labels used in the EEG layout
%                         
% OUTPUT
% elec - an elec structure
%
% e.g.:  elec =  elecCreate({'Fp1','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','O2'}); 

%%
elecFile = which('standard_1020.elc'); % in mm, in the MNI coordinate system
elecTemp = ft_read_sens(elecFile);
elec = elecTemp;

% Take only valid electrodes
elec.label = validEEGLabels';
for i = 1:length(validEEGLabels)
    label = validEEGLabels{i};
    index = find( strcmp(label,elecTemp.label));
    elec.chanpos(i,:) = elecTemp.chanpos(index,:);
    elec.elecpos(i,:) = elecTemp.elecpos(index,:);
end
% and delete all unnecesaary data
elec.elecpos(i+1:end,:) = [];
elec.chanpos(i+1:end,:) = [];

end

