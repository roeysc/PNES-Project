function atlas = spmAtlas2ftAtlas(atlas, labels)
% spmAtlas2ftAtlas is a bad patch function that fixes the structure
% of an atlas from an spm format to match that of fieldtrip format.
% 1) It changes the following fields name:
%    'brick0' --> 'tissue'
%    'brick0label' --> 'tissuelabel'
% 2) It fixes the 'coordsys' field to be 'mni'
% 3) It changes the labels to match those of the the 'labels' struct
%
% This function is useful for changing the format of the atlas that we get
% using the fuction make_mask_joined_rois.
%
% This function uses the function "RenameField" which can be downloaded
% here: http://www.mathworks.com/matlabcentral/fileexchange/28516-renamefield/content//RenameField.m
%
% e.g.
% labels = load2struct('C:\Users\Roey\Documents\MATLAB\Roey_scripts\aal_labels.mat')
% atlas = ft_read_atlas('C:\Users\Roey\Documents\MATLAB\Roey_scripts\aal_memory_clusters.nii')
% atlas = spmAtlas2ftAtlas(atlas, labels)

atlas = RenameField(atlas, {'brick0','brick0label'}, {'tissue', 'tissuelabel'});
atlas.coordsys = 'mni';
atlas.tissuelabel = labels;

% The following lines are taken from ft_read_atlas, and are used to turn
% the tissue values 1:116, instead of 2001 etc.:

% "The original contains a rather sparse labeling, since not all indices
% are being used (it starts at 2001) The question is whether it is more
% important to keep the original numbers or to make the list with
% labels compact."

[a, i, j] = unique(atlas.tissue);
atlas.tissue = reshape(j-1, atlas.dim);

end