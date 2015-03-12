function gridVar = getRidOfCerrebellum(cfg, gridVar)
% getRidOfCerrebellum uses the aal atlas to set all nodes in the cerebellum
% as "outside", so they are not used in source reconstruction.

% e.g.
% gridVar = load2struct('C:\Users\roeysc\Desktop\PNES\MRI\realigned\segmented\grids\template_grid_singlesphere_with_Cerrebellum.mat')
% getRidOfCerrebellum([], gridVar);

if ~isfield(cfg, 'atlasPath')
    ftPath = which('ft_defaults');
    indices = find(ftPath == filesep);
    ftPath(indices(end)+1:end) = [];
    atlasPath = [ftPath 'template' filesep 'atlas' filesep 'aal' filesep 'ROI_MNI_V4.nii'];
    
    warning('AAL atlas will be used as default.')    
end

if ~isfield(cfg, 'ROIsToDiscard')
    ROIsToDiscard = [91:116];
end

% Load atlas
atlas = ft_read_atlas(atlasPath);
atlas = ft_convert_units(atlas, 'cm');
atlas.coordsys = 'mni'; % TODO: this is done in favor of line 206 in ft_volumelookup

% Turn ROIsToDiscard  to cell array with ROIs as strings
ROIsToDiscard = atlas.tissuelabel(ROIsToDiscard);


% Find all nodes in ROIsToDiscard
tmpcfg = [];
tmpcfg.atlas = atlas;
tmpcfg.coordsys = 'mni';
tmpcfg.inputcoord = 'mni';

for roiI = 1:length(ROIsToDiscard)
    tmpcfg.roi = ROIsToDiscard{roiI};
    roi_mask = ft_volumelookup(tmpcfg,gridVar); % TODO: DOES IT REALLY GIVE CORRECT VOXELS?
    
    discardInside = find(ismember(gridVar.inside, find(roi_mask(:))) );
        gridVar.inside(discardInside) = [];
    
    gridVar.outside(end+1:end+length(find(roi_mask(:)))) = find(roi_mask(:));
        gridVar.outside = unique(gridVar.outside);
end


end