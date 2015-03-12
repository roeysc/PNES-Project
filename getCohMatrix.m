function cohMat = getCohMatrix(cfg, data)
% getCohMatrix computed the coherence matrix of wanted nodes in data
%
% INPUT:
%               a raw data signal (as obtained with getSourceVirtualChannels for example)
%               cfg.roisFile: reigons of interest for which to compute coherence (default: 'all')
%               TODO: add a possibility to use ROIs indices
%               frequencies of interest limits in Hz (i.e.: [4 8])  [could be 1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48]
%               cfg.
%
% e.g. cfg.roisFile = 'C:\Users\roeysc\Desktop\PNES\hippocampus_rois.xlsx'; coh = getCohMatrix(cfg, envelopeData);
    
    roisFile = cfg.roisFile;

    cfg = [];
    cfg.method = 'mtmfft';
    cfg.output = 'powandcsd'; %'powandcsd';
    cfg.taper = 'hanning';
    cfg.foilim = [0 18]; %TODO: which frequencies are good? maybe only much slower?
    cfg.channelcmb = channelCombinationArray(roisFile); % or: {'all' 'all'};
    cfg.keeptrials = 'yes';
%     cfg.pad = 10; % TODO: do we want to do any padding at all?
    freq = ft_freqanalysis(cfg,data);

    %calculate coherence
    cfg = [];
    cfg.method = 'coh';
    
    cfg.complex = 'imag'; % TODOTODOTODOTODO: This is something I might want to ommit, as well as line 35
    
    cfg.jackknife = 'yes';
    cfg.trials = 'all'; % TODO: maybe this has got to be done in a loop, to get trial based coherence?
    cohMat = ft_connectivityanalysis(cfg, freq);
    
    if isfield(cfg, 'complex')
        if strcmp(cfg.complex, 'imag')
            cohMat.cohspctrm = abs(cohMat.cohspctrm);
        end
    end
    
end


% % % %% Compute Envelope Power Spectrum
% % % % calculate powerspectrum of hilbert data
% % % powcfg = [];
% % % powcfg.method = 'mtmfft';
% % % powcfg.channel = 'all';
% % % powcfg.output = 'pow';
% % % powcfg.keeptrials = 'yes';
% % % powcfg.taper = 'hanning';
% % % powcfg.foilim = [1 60]; % TODO: decide how to define the foilim.
% % % 
% % % fft_hilbert = ft_freqanalysis(powcfg,envelopeData);

% % % % plot powerspectrum
% % % cfg = []
% % % cfg.xlim = [1 20];
% % % figure; ft_singleplotER(cfg,fft_hilbert);