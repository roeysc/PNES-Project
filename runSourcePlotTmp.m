function [ output_args ] = runSourcePlotTmp(source)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    cfg = [];
%     cfg.MRI = 'C:\Users\roeysc\Desktop\PNES\MRI\realigned\pGR1992.mat';
%     cfg.MRI = which('single_subj_T1.nii');
    
    cfg.MRI = 'C:\Users\Roey\Documents\EEG_PNES\MRI\realigned\spmTemplate.mat';
    cfg.templateGrid = 'C:\Users\Roey\Documents\EEG_PNES\MRI\realigned\segmented\grids\template_grid_singlesphere.mat';
    cfg.avg = 'no';
    cfg.trialNum = 1;
    cfg.method = 'ortho'; %'slice', 'ortho'
    sourcePlot(cfg, source);
end