function elecRealign( inputDir )
% ELECREALIGN interactively creates an electrode structure based on mesh
% headshape structure created with "mriMesh" for use in source reconstruction analysis
% and saves them to that directory with prefix "elec_"
%
% INPUT
% inputDir - a directory with "mat" files containing mesh MRI files
%                        obtained via "mriMesh" (where struct is called "mrimesh")
%  
% TIPS: if mesh looks terrible, try resegmenting the MRI using higer
%              threshold for scalp tissue, and then rerunning "mriMesh"
%                   
% e.g.:  elecRealign( 'C:\Users\roeysc\Desktop\PNES\MRI\realigned\segmented' )
% 

%% backslah fix
if (inputDir(end)~='\')
    inputDir(end+1) = '\';
end

%% Create basic electrodes structure
validEEGLabels = {'Fp1','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','O2'};
elec = elecCreate(validEEGLabels); % in mm, in the MNI coordinate system
elec = ft_convert_units(elec,'cm'); % Convert to cm
elecBefore = elec;

%% Load Mesh Files and Interactively Realign the Electrodes
filesInDir = dir([inputDir 'mesh_*.mat']);
for i=1:length(filesInDir)
    
    fileName = filesInDir(i).name;
    
    cfg = [];
    cfg.method = 'interactive'; % 'interactive' or 'manual'
    cfg.warp = 'globalrescale';
    cfg.elec= elec;
    mrimesh = load([inputDir, fileName ])
    mrimesh = mrimesh.mrimesh;
    cfg.headshape = mrimesh ;
    elecTemp = ft_electroderealign(cfg);
    
    % save electrodes file
    save([inputDir 'elec_' fileName(6:end)], 'elecTemp');

end

end