function create_lab_quickcap64_mcn_no_cb()
% create_lab_quickcap64_mcn_no_cb creates electrodes layout based on the fieldtrip
% layout quickcap64. The electrodes names are in the MCN system (used by
% all relevant fieldtrip structures like elec, layout etc), e.g. T7 instead
% of T3, P7 instead of T5 etc. 
%
% Note that the no_cb part means the cerrebellum electrodes CB1, CB2 are
% excluded.
%
% NOTE: no changes were done to 'outline' and 'mask' fields.
% Also note that this is not necessarily the exact locations, since each
% layout is a little different. Even the same electrode (e.g. O1) has
% slightly different locations in different layouts.
%
% TODO: check if the order matters


lab_quickcap64_mcn_no_cb = load2struct(fullfile(which('quickcap64.mat'))); % lab_quickcap64  is based on the quickcap64

% Remove non-existing electrodes
indices = [];
for i = 1:length(lab_quickcap64_mcn_no_cb.label)
    switch lab_quickcap64_mcn_no_cb.label{i}
        case 'FT7'
            indices(end+1) = i;
        case 'FT8'
            indices(end+1) = i;
        case 'CB1'
            indices(end+1) = i;
        case 'CB2'
            indices(end+1) = i;
    end
end

lab_quickcap64_mcn_no_cb.pos(indices,:) = [];
lab_quickcap64_mcn_no_cb.width(indices,:) = [];
lab_quickcap64_mcn_no_cb.height(indices,:) = [];
lab_quickcap64_mcn_no_cb.label(indices,:) = [];

lay = lab_quickcap64_mcn_no_cb; % all layouts in fieldtrip are called 'lay'


% Save and plot the layout for everyone to see 
save(fullfile(fileparts(fullfile(which('quickcap64.mat'))), 'lab_quickcap64_mcn_no_cb'), 'lay');

cfg = [];
cfg.layout = fullfile(fileparts(fullfile(which('quickcap64.mat'))), 'lab_quickcap64_mcn_no_cb');
layout = ft_prepare_layout(cfg);

figure
ft_plot_lay(layout);
title('lab quickcap64 mcn no cb');

end