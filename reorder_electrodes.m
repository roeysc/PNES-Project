function elecNew = reorder_electrodes(elec, label)
% reorder_electrodes redefines the order of the electrodes in the elec
% struct to match that of the label (so it will be consistant with the data
% itself).
%
% INPUT
% elec: elec structre, as obtained from ft_read_sens
% label: cell array of strings with electrode labels
%
% OUPUT
% elecNew: the reordered elec structure

elecNew = elec;
elecToSaveIndices = find(ismember(lower(elec.label), lower(label)));

elecNew.chanpos = elecNew.chanpos(elecToSaveIndices,:);
elecNew.elecpos = elecNew.elecpos(elecToSaveIndices,:);
elecNew.label = elecNew.label(elecToSaveIndices,:);


end