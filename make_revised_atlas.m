% Make a revised AAL atlas

ftPath = which('ft_defaults');
indices = find(ftPath == filesep);
ftPath(indices(end)+1:end) = [];
    original_mask_filename  = [ftPath 'template' filesep 'atlas' filesep 'aal' filesep 'ROI_MNI_V4.nii'];

% % % % using the clusters of Michael's work on the Hippocampus network % % % %
% % % output_filename = 'C:\Users\Roey\Documents\MATLAB\Roey_scripts\aal_memory_clusters.nii';
% % % area_list = [];
% % % area_list{1} = [44 48 55 56];
% % % area_list{2} = [73 77 78];
% % % area_list{3} = [22 23 27 28];
% % % area_list{4} = [35 36];
% % % area_list{5} = [37 38 39 40 41 42];
% % % area_list{6} = [83 85 87];
% % % area_list{7} = [84 86 88];

% % % % make a corse aal atlas based on anatomy only % % % %
output_filename = 'C:\Users\Roey\Documents\MATLAB\Roey_scripts\aal_coarse.nii';
area_list = [];
area_list{1} = [43 45 47 49 51 53 55];
area_list{2} = [44 46 48 50 52 54 56];
area_list{3} = [21 22 35 36 37 38 39 40 41 42 67 68 69 70];
area_list{4} = [31 32 33 34];
area_list{5} = [71 72 73 74 75 76 77 78];
area_list{6} = [18 30 80 82 84 86 88 90];
area_list{7} = [17 29 79 81 83 85 87 89];
area_list{8} = [58 60 62 64 66];
area_list{9} = [57 59 61 63 65];
area_list{10} = [2 4 6 8 12 14 16 24 26];
area_list{11} = [1 3 5 7 11 13 15 23 25];
area_list{12} = [19 20];
area_list{13} = [9 10 27 28];
area_list{14} = [91:116];


make_mask_joined_rois(original_mask_filename, area_list, output_filename);
