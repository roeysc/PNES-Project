%% 
ftPath = which('ft_defaults');
indices = find(ftPath == filesep);
ftPath(indices(end)+1:end) = [];
atlasPath = [ftPath 'template' filesep 'atlas' filesep 'aal' filesep 'ROI_MNI_V4.nii'];

atlasAal = ft_read_atlas(atlasPath);

atlasRoey = ft_read_atlas(which('aal_coarse.nii')); % or check 'aal_memory_clusters.nii'

% Change atlas to fieldtrip format if it is in spm format
if isfield(atlasRoey , 'brick0')
    labels = load2struct(which('aal_labels.mat'));
    atlasRoey = spmAtlas2ftAtlas(atlasRoey, labels);
end


% Make sure the atlases are not identical
unique(atlasRoey.tissue == atlasAal.tissue)


%%
figure
slice = 60;

subplot(1,2,1)
imagesc(squeeze(atlasAal.tissue(slice ,:,end:-1:1))')
title('AAL')
subplot(1,2,2)
imagesc(squeeze(atlasRoey.tissue(slice ,:,end:-1:1))')
title('My atlas')