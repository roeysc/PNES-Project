function [output] = getAtlasFft(data)
% getAtlasFft computes FFT in atlas space and returns a structre of
% trials X ROIS X frequency X time
%
% NOTE: a constant trial length is assumed
%
% See this useful walkthrough: http://fieldtrip.fcdonders.nl/walkthrough

fsample = 256; % FIXME: we must have the fsample in the source space

T = data.time{1}(end);
frayleigh = 1/T; % the Rayleigh frequency - the frequency resolution

cfg = [];
cfg.method = 'mtmconvol'; % multitaper time-frequency transformation based on multiplication in the frequency domain. MTM is 'multitaper method' 
                          % NOTE: we could also use WAVELET like Hipp did in his paper
cfg.output = 'fourier';
cfg.foi = 1:48;
cfg.toi = 0:1/fsample:10; % time of interest: center of time windows to keep in output (see http://mailman.science.ru.nl/pipermail/fieldtrip/2012-December/006005.html)
                     % That is, every 10ms we get the fourier transform
cfg.t_ftimwin = 3./cfg.foi; % length of wavelet window per frequency (this was chosen according to the walkthrough, so as to get 3 cycles per window)
cfg.keeptrials = 'yes';
cfg.taper = 'hanning';
% numsmobin = 2; % FIXME
% cfg.tapsmofrq = 0.5 * frayleigh + numsmobin * frayleigh * ones(1,size(cfg.foi,2)); % FIXME: this is the frequency smoothing
cfg.tapsmofrq = 0.4 * cfg.foi; % FIXME: this is the width of frequency smoothing in Hz. Note that 4 Hz smoothing means plus-minus 4 Hz, i.e. a 8 Hz smoothing box.

cfg.feedback = 'none';

output = ft_freqanalysis(cfg, data);

end