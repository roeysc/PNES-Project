function create_lab_quickcap64_not_mcn()
% create_lab_quickcap64_not_mcn creates electrodes layout based on the fieldtrip
% layout quickcap64. The electrodes names are not in the MCN system,
% e.g. T3 instead of T7, T5 instead of P7 etc. 
%
% NOTE: no changes were done to 'outline' and 'mask' fields.
% Also note that this is not necessarily the exact locations, since each
% layout is a little different. Even the same electrode (e.g. O1) has
% slightly different locations in different layouts.
%
% TODO: check if the order matters

% Change electrodes names to fit those used in the lab cap
lab_quickcap64_not_mcn = load2struct(fullfile(which('quickcap64.mat'))); % lab_quickcap64  is based on the quickcap64
for i = 1:length(lab_quickcap64_not_mcn.label)
    switch lab_quickcap64_not_mcn.label{i}
        case 'AF3'
            lab_quickcap64_not_mcn.label{i} = 'F3A';         
        case 'AF4'
            lab_quickcap64_not_mcn.label{i} = 'F4A';            
        case 'FC5'
            lab_quickcap64_not_mcn.label{i} = 'C5A';            
        case 'FC3'
            lab_quickcap64_not_mcn.label{i} = 'C3A';            
        case 'FC1'
            lab_quickcap64_not_mcn.label{i} = 'C1A';            
        case 'FCZ'
            lab_quickcap64_not_mcn.label{i} = 'CZA';            
        case 'FC2'
            lab_quickcap64_not_mcn.label{i} = 'C2A';            
        case 'FC4'
            lab_quickcap64_not_mcn.label{i} = 'C4A';            
        case 'FC6'
            lab_quickcap64_not_mcn.label{i} = 'C6A';            
        case 'T7'
            lab_quickcap64_not_mcn.label{i} = 'T3';            
        case 'T8'
            lab_quickcap64_not_mcn.label{i} = 'T4';            
        case 'CPZ'
            lab_quickcap64_not_mcn.label{i} = 'PZA';            
        case 'CP1'
            lab_quickcap64_not_mcn.label{i} = 'C1P';            
        case 'CP3'
            lab_quickcap64_not_mcn.label{i} = 'C3P';            
        case 'CP5'
            lab_quickcap64_not_mcn.label{i} = 'TCP1';            
        case 'TP7'
            lab_quickcap64_not_mcn.label{i} = 'T3L';            
        case 'CP2'
            lab_quickcap64_not_mcn.label{i} = 'C2P';            
        case 'CP4'
            lab_quickcap64_not_mcn.label{i} = 'C4P';            
        case 'CP6'
            lab_quickcap64_not_mcn.label{i} = 'TCP2';            
        case 'TP8'
            lab_quickcap64_not_mcn.label{i} = 'T4L';
        case 'P7'
            lab_quickcap64_not_mcn.label{i} = 'T5';            
        case 'P8'
            lab_quickcap64_not_mcn.label{i} = 'T6';            
        case 'POZ'
            lab_quickcap64_not_mcn.label{i} = 'PZP';            
        case 'PO3'
            lab_quickcap64_not_mcn.label{i} = 'P1P'; 
        case 'PO4'
            lab_quickcap64_not_mcn.label{i} = 'P2P'; 
        case 'PO5'
            lab_quickcap64_not_mcn.label{i} = 'P3P'; 
        case 'PO6'
            lab_quickcap64_not_mcn.label{i} = 'P4P'; 
        case 'CB1'
            lab_quickcap64_not_mcn.label{i} = 'ob1'; 
        case 'CB2'
            lab_quickcap64_not_mcn.label{i} = 'ob2'; 
    end        
end

% Remove non-existing electrodes
indices = [];
for i = 1:length(lab_quickcap64_not_mcn.label)
    switch lab_quickcap64_not_mcn.label{i}
        case 'FT7'
            indices(end+1) = i;
        case 'FT8'
            indices(end+1) = i;
    end
end

lab_quickcap64_not_mcn.pos(indices,:) = [];
lab_quickcap64_not_mcn.width(indices,:) = [];
lab_quickcap64_not_mcn.height(indices,:) = [];
lab_quickcap64_not_mcn.label(indices,:) = [];

lay = lab_quickcap64_not_mcn; % all layouts in fieldtrip are called 'lay'


% Save and plot the layout for everyone to see 
save(fullfile(fileparts(fullfile(which('quickcap64.mat'))), 'lab_quickcap64_not_mcn'), 'lay');

cfg = [];
cfg.layout = fullfile(fileparts(fullfile(which('quickcap64.mat'))), 'lab_quickcap64_not_mcn');
layout = ft_prepare_layout(cfg);

figure
ft_plot_lay(layout);
title('lab quickcap64 not mcn');

end
