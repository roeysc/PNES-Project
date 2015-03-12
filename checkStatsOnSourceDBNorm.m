%% Run statistics on existing source reconstructio files - NORMALIZED TO MNI

sourceCondition1 = load('C:\Users\roeysc\Desktop\PNES\sourceDB\8-13\pLT1997_R_C_ConditionFilter_Norm.mat');
    sourceCondition1 = sourceCondition1.sourceCondition1Norm;
sourceCondition2 = load('C:\Users\roeysc\Desktop\PNES\sourceDB\8-13\pLT1997_R_O_ConditionFilter_Norm.mat');
    sourceCondition2 = sourceCondition2.sourceCondition1Norm;

mriFile = ft_read_mri('C:\Users\roeysc\Desktop\PNES\MRI\single_subj_T1.nii'); 
    
design = [ ones(1,length(sourceCondition1)),   2*ones(1,length(sourceCondition2)) ];

cfg = [];
cfg.dim = sourceCondition1{1,1}.dim; 
cfg.method = 'montecarlo';
cfg.statistic = 'indepsamplesT';
cfg.parameter = 'pow';
cfg.correctm = 'cluster';
cfg.numrandomization = 1000;
cfg.alpha = 0.01;
cfg.tail = 0; % OR FIX THE TAIL?
cfg.design(1,:) = design;
cfg.ivar = 1; % row of design matrix that contains independent variable (the conditions)

stat = ft_sourcestatistics(cfg, sourceCondition1{1,1},sourceCondition1{1,2}, sourceCondition2{1,1}, sourceCondition2{1,2});
% stat = ft_sourcestatistics(cfg, sourceCombined); % THIS WAS USED WHEN ANALYSIS WAS PERFORMED USING A COMMON FILTER


probNoNAN = stat.prob(~isnan(stat.prob)); % check if there is a place where ~p=1
find(probNoNAN~=1)
if ~isempty(ans)
            %% Plot Probability Statistics
            % mriFile = ft_read_mri(mriFile); % MARKED WITH % SINCE THIS WAS DONE ABOVE
            mriFile = ft_volumereslice([ ],mriFile );
            ft_convert_units(mriFile, 'cm');
            
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
end

