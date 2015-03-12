close all;
clear; clc;
% sourceAnalysisStatInSubject performs source analysis statistics between
% conditions and plots the brain activity

%% Bands of Interest
bands = [1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48]; % These were used in Shahar's article

%%
patients = { 'pSS1984'};%,  'pSN1993',  'pLT1997'};

sourceCondition1 = cell(1,length(patients));
sourceCondition2 = cell(1,length(patients));

for patientI = 1:length(patients)
        %% Query two conditions
        query({patients{patientI}}, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced', 'R', 'O', 'A',1,1,1, 'Condition1');
        query({patients{patientI}}, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced', 'R', 'C', 'A',1,1,1, 'Condition2');
        
        queryFile1 = 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\queries\Condition1';
        queryFile2 = 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\queries\Condition2';
        mriFile = ft_read_mri( ['C:\Users\roeysc\Desktop\PNES\MRI\' patients{patientI} '.hdr'] ); % CHECKME WE HAVE TO FIND THE TEMPLATE MRI FILE (MNI)
        segmentedMriFile = ['C:\Users\roeysc\Desktop\PNES\MRI\segmented\tpm_segmented_' patients{patientI} '.mat' ];%%%%%%%%%%%%%%%%%%%%%%%%%

        %% Perform Source Analysis
        % Define cfg for sourceAnalysisWrap
        cfg = [];
        cfg.output = 'powandcsd';
        cfg.analysistype = 'smoothing'; % 'maxperlen' or 'smoothing'
        cfg.foilim = [4 8]; % to be configured in forthcoming loop
        cfg.keeptrials = 'yes';
         [ sourceCondition1{patientI}, sourceCondition2{patientI} ] = sourceAnalysisWrap( cfg, segmentedMriFile, queryFile1, queryFile2);
end
 
%
%%%
%%% BEGGINING OF CHECK 

% % % % Try to interpolate by trial
source = sourceCondition1{1}; % source of patient 1



% Volume-Normalize the Source Reconstruction Structure
cfg = [];
cfg.spmversion  = 'spm8';
cfg.coordsys = 'spm'; %WE HAVE TO CHECK THAT
cfg.nonlinear  = 'no';
statplotNorm = ft_volumenormalise(cfg, source);


%%% END OF CHECK
%%%
%
 
 %% Source Analysis Statistics
 % Create the design vector using condition1 and condition2
design = [ ones(1,length(sourceCondition1.trial)),   2*ones(1,length(sourceCondition2.trial))  ];

cfg = [];
cfg.dim = sourceCondition1.dim; 
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT';
cfg.parameter = 'pow';
cfg.correctm = 'cluster';
cfg.numrandomization = 5000;
cfg.alpha = 0.05;
cfg.tail = 0; % OR FIX THE TAIL?
cfg.design(1,:) = design;
            % OR for paired test (as in the tutorial)
            % cfg.design(1,:) = [1:length(find(design==1)) 1:length(find(design==2))];
            % cfg.design(2,:) = design;
            % AND MAYBE
            % cfg.uvar = 1; % row of design matrix that contains unit variable (in this case: trials) %%% APPARENTLY THIS IS NOT USED AND CREATES ERROR
cfg.ivar = 1; % row of design matrix that contains independent variable (the conditions)

stat = ft_sourcestatistics(cfg, sourceCondition1, sourceCondition2);
% stat = ft_sourcestatistics(cfg, sourceCombined); % THIS WAS USED WHEN ANALYSIS WAS PERFORMED USING A COMMON FILTER

%% Plot Probability Statistics
mriFile = ft_read_mri(mriFile);
mriFile = ft_volumereslice([ ],mriFile );
 
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
