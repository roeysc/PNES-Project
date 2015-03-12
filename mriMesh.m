function mriMesh( inputDir )
% MRIMESH creates a "bnd" file of the patients' MRI files in given directory for the electrode realignment
% and saves them to that directory with prefix "mesh_"
%
% INPUT
% inputDir - a directory with "mat" files containing realigned scalp MRI structures
%                        obtained via "segmentMRI" (where struct is called "scalp_segmentedmri")
%  
% TIPS: if mesh looks terrible, try resegmenting the MRI using higer
%              threshold for scalp tissue
%                   
% e.g.:  mriMesh( 'C:\Users\roeysc\Desktop\PNES\MRI\realigned\segmented' )

%% backslah fix
if (inputDir(end)~='\')
    inputDir(end+1) = '\';
end

%% Load and Convert each segmented MRI file
filesInDir = dir([inputDir 'tpm_*.mat']); %%% TODO: or for specific tissue: filesInDir = dir([inputDir 'tpm_*.mat']);

for i=1:length(filesInDir)

    % read MRI
    fileName = filesInDir(i).name;
    segmentedmri = load2struct([inputDir fileName]);
    
    % Create Mesh for the Head Model
    cfg = [];
    cfg.tissue = {'gray'}; %%% TODO: or for specific tissue: cfg.tissue = {'white'};
    cfg.numvertices = [4000];
    mrimesh = ft_prepare_mesh(cfg,segmentedmri);
    figure
    ft_plot_mesh(mrimesh);

    % save mesh file
    indices = find(fileName == '_');
    
    save([inputDir 'mesh_' fileName(indices(2)+1:end)], 'mrimesh');
end

end