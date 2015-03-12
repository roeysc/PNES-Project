function [ sourceNormalised ] = sourceInterpoateAndNormalise( source, mriStruct )
% This function returns the source reconstruction structure normalised to MNI, per trial
% INPUT: source - a source structure obtained via ft_sourceanalysis.
%                mriStruct - an MRI struct obtained via ft_read_mri
% OUTPUT: sourceNormalised - the source structure  normalisedto MNI coordinates 
%
% NOTE: Normalisation is performed per trial.

anatomical = mriStruct;
trialsNum = length(source.trial);

sourceInterpolated = cell(1,trialsNum);
functional = source;
functional = rmfield(functional,'trial');
functional.df = 1; % "functional" will only have one trial at a time
cfg.parameter = 'pow';

sourceNormalised = cell(1,trialsNum);
cfgNorm = [];
cfgNorm.spmversion  = 'spm8';
cfgNorm.coordsys = 'spm'; %WE HAVE TO CHECK THAT
cfgNorm.nonlinear  = 'no';

CHECK = ft_sourceinterpolate(cfg, source,anatomical);

for trialI = 1:trialsNum
    % Interpolate each trial
    functional.pow = source.trial(trialI).pow;
    sourceInterpolated{trialI} = ft_sourceinterpolate(cfg, functional,anatomical);

    %Normalise each trial
    sourceNormalised{trialI} = ft_volumenormalise(cfgNorm, sourceInterpolated{trialI});
end

end

