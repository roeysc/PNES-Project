function [ output_args ] = sourcePlot(cfg, source)
%plot results of source analysis
%   INPUT:
%       - cfg: configuration struct with the following fields:
%           - MRI: path to a realigned MRI file, the template MNI grid (using
%           the same method as used in sourceAnalysis)
%           - templateGrid - path to template grid, created using
%                       createSubjectMNIGrid.
%           - avg: 'yes'/'no' - plot average activity. default - yes
%           - method: method for source plot.
%                       options: {'slice', 'ortho', 'surface'} see ft_sourceplot
%                       default: 'slice'
%           - trialNum: the number of the trial to plot
%       - source: the struct which is the result of sourecAnalysis
%
%   NOTE
%       The  ft_sourceinterpolate function doesn't work well on time course
%       signal (but can be used n source statistics or source power spectrum).
%       Using source trials with time will cause the error "Wrong number of input arguments or some dimension
%       of V is less than 2."


    if (~isfield(cfg, 'avg'))
        if (~isfield(cfg, 'trialNum'))
            cfg.avg = 'yes';
        else
            cfg.avg = 'no';
        end
    end
    
    if (~isfield(cfg,'method'))
        cfg.method = 'slice';
    end
    
    if (~isfield(cfg,'templateGrid') || ~isfield(cfg,'MRI'))
        error('must have template grid and MRI path!');
    end
    
    %load template grid as template_grid (a struct)
    load(cfg.templateGrid);
    
    %warping source to template grid. TODO: this should be optional
    source.pos = template_grid.pos;
    source.dim = template_grid.dim;
        
    srcplt_cfg = struct;
    %srcplt_cfg.surffile = which('surface_l4_both.mat');
    srcplt_cfg.method = cfg.method;
    if (strcmp(cfg.avg,'yes'))
        srcplt_cfg.funparameter = 'avg.pow' ;
    elseif isfield(cfg, 'trialNum')
       srcplt_cfg.funparameter = 'pow';
       % srcplt_cfg.funparameter = ['(trial(' num2str(cfg.trialNum) ')).pow'];
       source.pow = source.trial(cfg.trialNum).pow;
    else
        error('must be either avg=yes or trialNum given');
    end
    
    srcitr_cfg = struct;
    srcitr_cfg.parameter = srcplt_cfg.funparameter;
%     srcitr_cfg.downsample = 2; 
    MRI = load2struct(cfg.MRI); %ft_read_mri(cfg.MRI);
    MRI = ft_volumereslice([], MRI);
                
                % ROEY ADDED TO CHECK PLOT ON TEMPLATE MRI
                MRI = ft_convert_units(MRI, 'cm')
                source = ft_convert_units(source, 'cm')
    
    sourceForPlot = ft_sourceinterpolate(srcitr_cfg, source, MRI);
    
%     srcplt_cfg.funcolorlim = [0.0, 1e4];
    
    ft_sourceplot(srcplt_cfg, sourceForPlot);

end

