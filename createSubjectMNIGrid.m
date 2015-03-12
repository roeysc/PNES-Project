function [] = createSubjectMNIGrid(mriPath, method, patientsNames)
% CREATESUBJECTMNIGRID defines the source-reconstruction grid for each individual
% subject such that each  grids is aligned in MNI-space.
%
% INPUT: mriPath - the directory whre REALIGNED MRI files of the subjects
%                                     are saved, and where there is a subdirectory called "segmented" with
%                                     segmented MRI files.
%                method - 'singlesphere' or 'concentricspheres' or 'openmeeg' etc., as a method to create the
%                                  volume-conductor model for leadfield computation in source analysis
%                patientsNames - cell array of the patients names to create grids for.
% 
% OUTPUT: No output, but subjects' grid in MNI space is saved to the
%                  "segmented" subdirectory with prefix "grid_METHOD_".
%
% e.g.: createSubjectMNIGrid('C:\Users\roeysc\Desktop\PNES\MRI\realigned','singlesphere',{'pGR1992'})
%
% NOTE: The code is based on the following tutorial (with mild changes):
% http://fieldtrip.fcdonders.nl/example/create_single-subject_grids_in_individual_head_space_that_are_all_aligned_in_mni_space
%
% DATA ABOUT DIFFERENT HEADMODELS:
% http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg

% backslah fix
if (mriPath(end)~='\')
    mriPath(end+1) = '\';
end

% (1) Make the template_grid in the normalized MNI space (if it doesn't already exist)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    if ~exist([mriPath 'segmented\grids'], 'dir')
        mkdir(mriPath, 'segmented\grids')
    end    
    
    if(~exist([mriPath,'template_grid_' method '.mat' ],'file'))
% % % % THE FOLLOWING LINES WERE USED WHEN WE THOUGHT WE COULD CREATE THE
% % % % TEMPLATE GRID AS SHOWN IN THE TUTORIAL. AIA PROPOSED USING THE TEMPLATE
% % % % FROM THE FULL FIELDTRIP VERSION
% % % % 
%%%%% first option - like in the tutorial
            templateDir = which('ft_defaults'); % use a known function (ft_defaults) to find FieldTrip's directory
            backslashIndices = find(templateDir=='\');
            templateDir(backslashIndices(end)+1:end) = [];      clear backslashIndices;
            templateDir = [templateDir, '\external\spm8\templates\T1.nii'];
            template = ft_read_mri(templateDir);                        clear templateDir;
            template.coordsys = 'spm'; % so that FieldTrip knows how to interpret the coordinate system

            % segment the template brain and construct a volume conduction model (i.e. head model): this is needed
            % for the inside/outside detection of voxels.
            cfg = [];
            template_seg = ft_volumesegment(cfg, template);

            cfg = [];
            cfg.method = method;
            template_vol = ft_prepare_headmodel(cfg, template_seg);
            template_vol = ft_convert_units(template_vol, 'cm'); % Convert the vol to cm, since the grid will also be expressed in cm

            % construct the dipole grid in the template brain coordinates
            % the source units are in cm
            % the negative inwardshift means an outward shift of the brain surface for inside/outside detection
            cfg = [];
            cfg.grid.xgrid  = -20:1:20;
            cfg.grid.ygrid  = -20:1:20;
            cfg.grid.zgrid  = -20:1:20;
% Or define resolution: CHECKME
%              cfg.grid.resolution = 1;
% Or use the atlas's dimensions: CHECKME: THIS DOESN'T WORK
%             cfg.grid.dim= [91 109 91];


            cfg.grid.unit = 'cm';
            cfg.grid.tight = 'yes';
            cfg.inwardshift = -1.5;
            cfg.vol = template_vol;
            template_grid = ft_prepare_sourcemodel(cfg); % ignore matlab's note: "template_grid" is used in the next line
            
            save([mriPath ,'\segmented\grids\template_grid_' method '.mat'],'template_grid');

%%% SECOND OPTION - USE T1 TO CREATE THE TEMPLATE GRID
% % %         templateDir = which('ft_defaults'); % use a known function (ft_defaults) to find FieldTrip's directory
% % %         backslashIndices = find(templateDir=='\');
% % %         templateDir(backslashIndices(end)+1:end) = [];      clear backslashIndices;
% % %         templateDirMri = [templateDir, '\external\spm8\templates\T1.nii'];
% % %         template_mri = ft_read_mri(templateDirMri);
% % %         template_mri.coordsys = 'spm'; % so that FieldTrip knows how to interpret the coordinate system
% % % 
% % %         % segment the template brain and construct a volume conduction model (i.e. head model): this is needed
% % %         % for the inside/outside detection of voxels.
% % %         cfg = [];
% % %         template_seg = ft_volumesegment(cfg,template_mri);
% % % 
% % %         % create template_vol for the grid
% % %         cfg = [];
% % %         cfg.method = 'singlesphere';
% % %         template_vol = ft_prepare_headmodel(cfg, template_seg);
% % %         template_vol = ft_convert_units(template_vol, 'cm'); % Convert the vol to cm, since the grid will also be expressed in cm
% % % 
% % %         % load the template grid
% % %         template_grid= load( [templateDir, '\template\sourcemodel\standard_sourcemodel3d10mm'] );

% % % %  WE DECIDED TO USE THE REGULAR TEMPLATE GRID ONLY
% % % %         % create the template grid (with 1 cm resolution)
% % % %         cfg= [];  
% % % %         cfg.mri = template_mri;
% % % %         cfg.grid.template  = template_grid.sourcemodel;
% % % %         cfg.grid.warpmni= 'yes';
% % % %         cfg.nonlinear='yes';
% % % %         cfg.vol = template_vol;
% % % %         cfg.sourceunits = 'cm'; 
% % % %         template_grid = ft_prepare_sourcemodel(cfg);

        save([mriPath ,'\segmented\grids\template_grid_' method '.mat'],'template_grid');
end

        
% (2) Make the individual subjects' grid
% % % % % % % % % % % % % % % % % % % % % %
    for patientI = 1:length(patientsNames)
        % read the single subject segmented anatomical MRI
        seg = load([mriPath, 'segmented\tpm_segmented_', patientsNames{patientI}]);
        seg = seg.tpm_segmentedmri;
        seg = ft_convert_units(seg, 'cm');
        %         cfg.coordsys = 'ctf'; CHECKME: maybe we should always check if it's ctf? And maybe we should downsample it by 2?
        
        % this is a good moment to check whether your segmented volumes are correctly 
        % aligned with the anatomical scan (see below) 

        % construct volume conductor model (i.e. head model) for each subject
        % this is optional, you can also use another model, e.g. a single sphere model
        cfg = [];
        cfg.method = method; 
        
        % for method='openmeeg', converting binary segmented MRI is needed:
        if strcmp(cfg.method, 'openmeeg')
            % TODO (this will only work on Linux)
        end
        vol = ft_prepare_headmodel(cfg, seg);

        % create the subject specific grid, using the template grid that has just been created
        cfg = [];
        cfg.grid.warpmni = 'yes';
        cfg.grid.template = load([mriPath , '\segmented\grids\template_grid_' method '.mat']);
                cfg.grid.template = cfg.grid.template.template_grid;
        cfg.grid.nonlinear = 'yes'; % use non-linear normalization
        cfg.mri = load([mriPath, patientsNames{patientI} '.mat']);
                cfg.mri = cfg.mri.mriReal;
        grid = ft_prepare_sourcemodel(cfg);

        % make a figure of the single subject headmodel, and grid positions
        figure;
        ft_plot_vol(vol, 'edgecolor', 'none'); alpha 0.4;
        ft_plot_mesh(grid.pos(grid.inside,:));
        title([patientsNames{patientI}, '''s  ' method '  Head Model']);
        
        % save file
        save([mriPath ,'\segmented\grids\grid_' method '_' patientsNames{patientI} '.mat'],'grid');

    end


