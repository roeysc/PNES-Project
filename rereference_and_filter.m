function filteredData = rereference_and_filter(cfg, rawData)
% rereference_and_filter gets raw data and returns it after rereferencing
% and filtering.
%
% INPUT
% cfg.reref       ('yes' or 'no'. default: no)
% cfg.channel     (the channels to be rereferenced. default: all)
% cfg.refchannel  (the new reference channel. default: all (meaning average
%                 refernece, but note that 'cfg.reref' is 'no' by default)
% cfg.lpfilter    (apply lowpass filter. 'yes' or 'no'. default: no)
% cfg.lpfreq      (lowpass frequency in Hz. default: 300)
% cfg.hpfilter    (apply highpass filter. 'yes' or 'no'. default: no)
% cfg.hpfreq      (highpass frequency in Hz. default: 0.1)
% cfg.dftfilter   (remove line noise (50Hz). default: 'no')
%
% OUTPUT
% The filtered data structre filteredData after rereferencing and filtering.
% 
% TIPS
% In case you get the following error:
%     Error using filter_with_correction (line 51)
%     Calculated filter coefficients have poles on or outside the unit circle and will
%     not be stable. Try a higher cutoff frequency or a different type/order of filter.
% Try to follow its instruction and indeed try a higher hpfreq or a
% different filter order (cfg.hpfiltord).
%
% See ft_preprocessing for more options.

refcfg.reref = ft_getopt(cfg, 'reref', 'no');
refcfg.channel = ft_getopt(cfg, 'channel', 'all');
refcfg.refchannel = ft_getopt(cfg, 'refchannel', 'all'); % 'all' gives the common average reference

rereferencedData = ft_preprocessing(refcfg, rawData);

filtcfg = [];
filtcfg.lpfilter = ft_getopt(cfg, 'lpfilter', 'no');
    filtcfg.lpfreq = ft_getopt(cfg, 'lpfreq', '300');
filtcfg.hpfilter = ft_getopt(cfg, 'hpfilter', 'no');
    filtcfg.hpfreq = ft_getopt(cfg, 'hpfreq', '0.1');
filtcfg.dftfilter = ft_getopt(cfg, 'hpfilter', 'no');

% % %
filtcfg.bsfilter = 'yes';
filtcfg.bsfreq = [48 52];
% % %

if (strcmp(filtcfg.dftfilter, 'yes'))
    cfg.padding = 10; % see: http://fieldtrip.fcdonders.nl/faq/what_kind_of_filters_can_i_apply_to_my_data
end


filteredData = ft_preprocessing(filtcfg, rereferencedData);

% add the original trialtype and interpolatedElectrodes fields
filteredData.labfield = rawData.labfield;

end