function sourceTrials = RunSourceAnalysisNew(recordStruct)
    % e.g. sourcePs = RunSourceAnalysisNew(PsTrials)
    
    
    ft_defaults
    fftcfg = struct;
    fftcfg.foilim = [4 8]; 
    fftcfg.output = 'powandcsd'; %power and cross spectral density
    fftcfg.keeptrials = 'yes';
    fftcfg.analysistype = 'smoothing';

    cfg = struct;
    cfg.patientName = 'spmTemplate'; % 'pGR1992'; % or the template "single_subj_T1"
    cfg.segMRIpath = 'C:\Users\Roey\Documents\Lab\PNES Project\PNES\MRI\realigned\segmented';
    
    cfg.recordStruct = recordStruct; % recordFile is the EEG recording (as recieved via "query.m")
    cfg.fftcfg = fftcfg;
    %cfg.method = 'dics';
%     cfg.method = 'eloreta';
    cfg.timeDomain = 'yes';
    cfg.method = 'mne';
    %cfg.method = 'lcmv';
    cfg.rawtrial = 'yes'; %this will project each single trial through the filter (and not compute the average source localization)
    
    sourceTrials = sourceAnalysisNew(cfg);
%     sourceTrials = sourceAnalysisBem(cfg);
end