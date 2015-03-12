% sourceAnalysisStatInSubject performs source analysis statistics between
% conditions and plots the brain activity

%% Set Path
path = 'C:\Users\Roey\Documents\EEG\DB\rereferenced\'; % Directory path with mat EEG files
mriPath = 'C:\Users\Roey\Documents\EEG\MRI\realigned\';
patientName = 'pGR1992'; % 'pSN1993','pLT1997','pSS1984'    LT: BEC-RC,  BPO-RO ; SS: PC-RC, PO-RO
foilim = [8 13];
outputName = 'just checking';%'SS1984_PO_RO_4_8_CommonFilter_BadInterpolation.mat';

%% Bands of Interest
bands = [1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48]; % These were used in Shahar's article

%% Query two conditions
query({patientName}, path, 'R', 'O', 'A',1,1,1,1, 'Condition1');
query({patientName}, path, 'R', 'C', 'A',1,1,1,1, 'Condition2');
% query({'pSN1993','pEC1980','pLT1997','pSG1991','pSS1984'}, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\normStandard', 'R', 'O', 'A', 1, 1, 1, 'RestOpen')
% query({'pSN1993','pEC1980','pLT1997','pSG1991','pSS1984'}, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\normStandard', 'R', 'C', 'A', 1, 1, 1, 'RestClosed')

queryFile1 = [path 'queries\Condition1'];
queryFile2 = [path 'queries\Condition2'];

mriFile = load([mriPath, patientName '.mat']); 
mriFile = mriFile.mriReal;
segmentedMriFile = [mriPath 'segmented\bss_segmented_' patientName '.mat']; %%% 21.01.2014 I changed this to make sure bss is used for grid computation

%% Perform Source Analysis
% Define cfg for sourceAnalysisWrap
cfg = [];
cfg.output = 'powandcsd';
cfg.analysistype = 'smoothing'; % 'maxperlen' or 'smoothing'
cfg.foilim = foilim;
cfg.keeptrials = 'yes';
cfg.method = 'openmeeg';% 'singlesphere', 'bemcp' (not 3 surfaces), 'dipoli' (not supported in windows), 'openmeeg'

% [ sourceCondition1, sourceCondition2 ] = sourceAnalysisWrap(cfg, segmentedMriFile, queryFile1, queryFile2); % uses a filter for each trial
% [ sourceCondition1, sourceCondition2 ] = sourceAnalysisWrapConditionFilter(cfg, segmentedMriFile, queryFile1, queryFile2); % uses a filter for each condition

[ sourceCondition1, sourceCondition2 ] = sourceAnalysisWrapCommonFilter(cfg, segmentedMriFile, queryFile1, queryFile2); % uses a common filter
 
save('C:\Users\Roey\Desktop\check_mri_script\workspace.mat')

%% Add the MNI template grid properties to the sources structures
% using output of the function "createSubjectMNIGrid.m"
template_grid = load([mriPath '\segmented\grids\template_grid_' cfg.method '.mat']);
    template_grid = template_grid.template_grid;

sourceCondition1.pos = template_grid.pos;
sourceCondition1.dim= template_grid.dim;
% % % sourceCondition1.xgrid= template_grid.xgrid;
% % % sourceCondition1.ygrid = template_grid.ygrid;
% % % sourceCondition1.zgrid = template_grid.zgrid;
sourceCondition2.pos = template_grid.pos;
sourceCondition2.dim= template_grid.dim;
% % % sourceCondition2.xgrid= template_grid.xgrid;
% % % sourceCondition2.ygrid = template_grid.ygrid;
% % % sourceCondition2.zgrid = template_grid.zgrid;

 %% Normalize the Source Structure:
% NOTE: THIS PART IS NO LONGER USED, BECAUSE WE USE THE MNI GRIDS, SO NO
% VOLUME NORMALISING IS NECESSARY
 % We normalize here because we want to use an atlas for different ROIs
%  sourceCondition1Norm = sourceInterpoateAndNormalise(sourceCondition1, mriFile);
%  sourceCondition2Norm = sourceInterpoateAndNormalise(sourceCondition2, mriFile);
  
 %% Source Analysis Statistics
 % Create the design vector using condition1 and condition2
design = [ ones(1,length(sourceCondition1.trial)),   2*ones(1,length(sourceCondition2.trial)) ];

cfg = [];
cfg.dim = sourceCondition1.dim; 
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT';
cfg.parameter = 'pow';
cfg.correctm = 'cluster';
cfg.numrandomization = 1000;
cfg.alpha = 0.01;
cfg.tail = 0; % OR FIX THE TAIL?
cfg.design(1,:) = design;
            % OR for paired test (as in the tutorial)
            % cfg.design(1,:) = [1:length(find(design==1)) 1:length(find(design==2))];
            % cfg.design(2,:) = design;
            % AND MAYBE
            % cfg.uvar = 1; % row of design matrix that contains unit variable (in this case: trials) %%% APPARENTLY THIS IS NOT USED AND CREATES ERROR
cfg.ivar = 1; % row of design matrix that contains independent variable (the conditions)

% % % % % % % CHECKME: use atlas for comparisons
% % % atlas = spm_read_vols(spm_vol('C:\Users\roeysc\Documents\MATLAB\DPARSF_V2.3_130615\Templates\AAL_resliced_61x73x61_v2_michael.nii'));
% % % [~,AAL_names] = xlsread('C:\Users\roeysc\Documents\MATLAB\Network_scripts\Data_new\AAL_nodes.xls');
% % % AAL_names_new=AAL_names(:,6); AAL_names=AAL_names(:,2);

% % %   cfg.atlas = 'C:\Users\roeysc\Documents\MATLAB\DPARSF_V2.3_130615\Templates\AAL_resliced_61x73x61_v2_michael.nii';
% % %   cfg.atlas = 'C:\Users\roeysc\Documents\MATLAB\fieldtrip-20130822\template\atlas\afni\TTatlas+tlrc.BRIK';
  
% % % % % % % %             % Load the Atlas
% % % % % % % %             templateDir = which('ft_defaults'); % use a known function (ft_defaults) to find FieldTrip's directory
% % % % % % % %             backslashIndices = find(templateDir=='\');
% % % % % % % %             templateDir(backslashIndices(end)+1:end) = [];      clear backslashIndices;
% % % % % % % %             templateDir = [templateDir, 'template\atlas\aal\ROI_MNI_V4.nii'];
% % % % % % % % 
% % % % % % % %             % Convert sources units to mm, to fit the atlas's units
% % % % % % % %             sourceCondition1 = ft_convert_units(sourceCondition1, 'mm');
% % % % % % % %             sourceCondition2 = ft_convert_units(sourceCondition2, 'mm');
% % % % % % % % 
% % % % % % % %             
% % % % % % % %             
% % % % % % % %             %% Check the sources dimension (are they like the MNI atlas?)
% % % % % % % %             % If not, reslice the sources to fit the  atlas
% % % % % % % %             %             cfg.dim = [91 109 91];
% % % % % % % %             %             sourceCondition1 = ft_volumereslice(cfg, sourceCondition1);
% % % % % % % %             % The atlas is here: C:\Users\roeysc\Documents\MATLAB\fieldtrip-20130822\template\atlas\aal                         
% % % % % % % %           cfg.atlas = templateDir;
% % % % % % % %           % Get roi numbers
% % % % % % % %           atlas = ft_read_atlas(cfg.atlas)
% % % % % % % %           cfg.roi = atlas.tissuelabel;
% % % % % % % %           cfg.roi(   find(strcmp(cfg.roi, 'Cerebelum_3_L'))   ) = [];
% % % % % % % %           
% % % % % % % %           clear atlas;
% % % % % % % % %             cfg.roi = AAL_names(1:5);
% % % % % % % % %             cfg.roi = cell(1,115);
% % % % % % % % %             for i = 1:115 % ignore 0 which is outside the brain
% % % % % % % % %                 cfg.roi{i} = num2str(i); %string or cell of strings, region(s) of interest from anatomical atlas
% % % % % % % % %             end
% % % % % % % %                   
% % % % % % % %             cfg.avgoverroi   = 'yes';
% % % % % % % %             cfg.hemisphere   = 'both';
% % % % % % % %             cfg.inputcoord   = 'mni';% 'mni' or 'tal', the coordinate system in which your source reconstruction is expressed

  % % % % % % % 

    stat = ft_sourcestatistics(cfg, sourceCondition1, sourceCondition2);
% stat = ft_sourcestatistics(cfg, sourceCombined); % THIS WAS USED WHEN ANALYSIS WAS PERFORMED USING A COMMON FILTER


probNoNAN = stat.prob(~isnan(stat.prob)); % check if there is a place where ~p=1
find(probNoNAN~=1)
if ~isempty(ans)
            %% Plot Probability Statistics
            % mriFile = ft_read_mri(mriFile); % MARKED WITH % SINCE THIS WAS DONE ABOVE
            
            %%%%%% Load the template MNI T1 image
                templateDir = which('ft_defaults'); % use a known function (ft_defaults) to find FieldTrip's directory
                backslashIndices = find(templateDir=='\');
                templateDir(backslashIndices(end)+1:end) = [];      clear backslashIndices;
                templateDir = [templateDir, '\external\spm8\templates\T1.nii'];
                mriFile = ft_read_mri(templateDir);                        clear templateDir;
                
            %%%%%%
            
            mriFile = ft_volumereslice([ ],mriFile);

            cfg = [];
            cfg.parameter = 'prob';    
            statplot = ft_sourceinterpolate(cfg, stat, mriFile); 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot the probability values on the MRI - SLICE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cfg = [];
            cfg.method = 'slice';
            cfg.funparameter = 'prob'; % DO WE WANT TO PLOT THE AVERAGE POWER INSTEAD?. Then we would have to do ft_sourceinterpolate in line 47 on sourceCondition1 and not on stat
            cfg.maskparameter = 'mask';
            % cfg.colormap = ; % see Matlab function COLORMAP
                        
            ft_sourceplot(cfg, statplot);

            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % % plot the probability values on the MRI - ORTHO
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cfg = [];
            cfg.method  = 'ortho';
            cfg.funparameter  = 'prob';
            cfg.maskparameter =  'mask';
            cfg.opacitymap    = 'rampup';  

            ft_sourceplot(cfg, statplot);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot the power values of each condition on the MRI - SLICE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            cfg = [];
            cfg.parameter = 'avg.pow';
            cfg.voxelcoord   = 'no';
            cfg.interpmethod = 'linear';
            cfg.coordsys = 'mni';
            powerplot1 = ft_sourceinterpolate(cfg, sourceCondition1, mriFile); 
            powerplot2 = ft_sourceinterpolate(cfg, sourceCondition2, mriFile); 
            
            minPower = min(min(sourceCondition1.avg.pow), min(sourceCondition2.avg.pow));
            maxPower = max(max(sourceCondition1.avg.pow), max(sourceCondition2.avg.pow));
            
            cfg = [];
            cfg.method = 'slice';
            cfg.funparameter = 'avg.pow'; % DO WE WANT TO PLOT THE AVERAGE POWER INSTEAD?. Then we would have to do ft_sourceinterpolate in line 47 on sourceCondition1 and not on stat
%             cfg.maskparameter = 'mask';
            ft_sourceplot(cfg, powerplot1);   title('power - condition 1');   caxis([5e11,6e11]);
            ft_sourceplot(cfg, powerplot2);   title('power - condition 2');   caxis([5e11,6e11]);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % plot the probability values on the MRI - SURFACE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % % normalize coordinates
            % cfg = [];
            % cfg.coordsys = 'ctf'; %WE HAVE TO CHECK THAT
            % cfg.nonlinear  = 'no';
            % statplotNorm = ft_volumenormalise(cfg, statplot);
            % 
            % cfg = [];
            % cfg.method = 'surface';
            % cfg.surffile = 'C:\Users\roeysc\Desktop\PNES\MRI\surface_l4_both.mat'; % ###### THIS COULD BEWRONG AND A REAL MRI FILE SHOULD BE USED ######
            % cfg.funparameter = 'prob';
            % cfg.maskparameter = cfg.funparameter;
            % cfg.funcolormap    = 'jet';
            % cfg.opacitymap = 'rampdown';
            % cfg.projmethod = 'nearest';
            % cfg.opacitylim     = [0 1];
            % cfg.surfdownsample = 10;
            % ft_sourceplot(cfg, statplotNorm);
            % 
            % % cfg.colormap = ; % see Matlab function COLORMAP
            % % ft_sourceplot(cfg, statplot);
end

save(['C:\Users\roeysc\Desktop\PNES\StatisticsChecks\' outputName])
