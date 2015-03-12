function mriSegment(cfg, inputDir)
% SEGMENTMRI creates segmented MRI files for all MRI mat files in given directory
% and saves them to a sub directory called "segmented"
%
% INPUT
% inputDir - a directory with "mat" files containing realigned MRI structures
%                        obtained via "mriRealign" (where struct is called "mriReal")
% cfg             - by default, unless cfg.plot is not 'no', the code plots the segmented tissue to check alignment with anatomy
%
% OUTPUT
% No output, but three segmented MRI files are saved for each patient to a subdirectory called "segmented":
%                    * "tpm_segmented_PATIENTNAME" (csf, white matter and gray matter)
%                    * "scalp_segmented_PATIENTNAME" (scalp). This is used to realign electrodes (see 'elecRealign')
%                    * "bss_segmentedmri_PARIENTNAME" (brain, scalp and skull ). This is used in creating the head model (see 'createMeshBasedHeadmodel')
% TIPS
% If holes appear in the segmentation try lowering "scalpthreshold" or increasing "scalpsmooth"
%
% e.g.:  mriSegment( 'C:\Users\roeysc\Desktop\PNES\MRI\realigned' )

%% backslah fix
if (inputDir(end)~='\')
    inputDir(end+1) = '\';
end

%% Add default plot if not state otherwise by user
if ~exist('cfg')
    cfg=[];
end
if ~isfield('cfg', 'plot')
    cfg.plot = 'yes';
end
doplot = cfg.plot;

%% Load and Convert each MRI file
filesInDir = dir([inputDir '\*.mat']);

for i=1:length(filesInDir)
    % read MRI
    fileName = filesInDir(i).name;
    mri = load2struct([inputDir fileName]);
%     mri = mri.mriReal;

    % reslice (WE USED TO DO IT BUT DECIDED AGAINST IT) CHECKME
    % % %     cfg = [];
    % % %     cfg.dim = [256 256 256];
    % % %     mri = ft_volumereslice(cfg,mri);   

    % volume segment (from the fieldtrip ft_volumesegment page and "Creating a volume conduction model of the head for shource_reconstruction of EEG data")
    cfg = [];
    cfg.write = 'no';
    cfg.coordsys = 'spm'; % used to be 'ctf'. should be 'spm' (which uses MNI)?
    cfg.scalpthreshold = 0.8; % take only those voxel where 0.25 < p %%%%%% 21.01.2014 I changed this to 0.1 to fix the hole
    cfg.scalpsmooth = 5; % default is 5

    % Create three different segmentations
    % (1)
    cfg.output = {'tpm'}; % csf, white matter and gray matter
    [tpm_segmentedmri] = ft_volumesegment(cfg, mri);
    % (2)
    cfg.output = {'scalp'}; % scalp
    [scalp_segmentedmri] = ft_volumesegment(cfg, mri);
    % (3)
    cfg.output = {'brain','skull','scalp'} %  brain, skull and scalp
    [bss_segmentedmri] = ft_volumesegment(cfg, mri);
    
    if strcmp(doplot, 'yes')     % check that segemented mri is aligned with anatomy
        scalp_segmentedmri.anatomy   = mri.anatomy; %this is only used for the plot and will be deleted later
        tpm_segmentedmri.anatomy   = mri.anatomy; % the same goes here

        cfg.funparameter = 'scalp';
        ft_sourceplot(cfg,scalp_segmentedmri); %segmented gray matter on top
        title([fileName(1:end-5) ' - scalp']);

        cfg.funparameter = 'gray';
        ft_sourceplot(cfg,tpm_segmentedmri);
        title([fileName(1:end-5) ' - gray matter']);

        cfg.funparameter = 'white';
        ft_sourceplot(cfg,tpm_segmentedmri);
        title([fileName(1:end-5) ' - white matter']);

        cfg.funparameter = 'csf';
        ft_sourceplot(cfg,tpm_segmentedmri);
        title([fileName(1:end-5) ' - csf ']);

        cfg.funparameter = 'scalp';
        ft_sourceplot(cfg,bss_segmentedmri);
        title([fileName(1:end-5) ' - scalp']);

        cfg.funparameter = 'skull';
        ft_sourceplot(cfg,bss_segmentedmri);
        title([fileName(1:end-5) ' - skull']);

        cfg.funparameter = 'brain';
        ft_sourceplot(cfg,bss_segmentedmri);
        title([fileName(1:end-5) ' - brain']);

        tpm_segmentedmri = rmfield(tpm_segmentedmri,'anatomy')
        scalp_segmentedmri = rmfield(scalp_segmentedmri,'anatomy')
    end

    % save mri file
    if ~exist([inputDir 'segmented'], 'dir')
        mkdir(inputDir, 'segmented')
    end

    fileName = fileName(1:end-4);
    save([inputDir 'segmented\tpm_segmented_' fileName '.mat'], 'tpm_segmentedmri');
    save([inputDir 'segmented\scalp_segmented_' fileName '.mat'], 'scalp_segmentedmri');
    save([inputDir 'segmented\bss_segmented_' fileName '.mat'], 'bss_segmentedmri');


    mriMesh([inputDir, 'segmented']);
    
end

end