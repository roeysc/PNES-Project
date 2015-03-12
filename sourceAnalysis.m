function [ sources ] = sourceAnalysis( cfg )
%Performs source analysis using ft_sourceanalysis for specific record
%   INPUT:
%       - cfg: configuration struct with the following fields:
%           - patientName - name of patient. If template MRI is used, use the name "single_subj_T1"
%           - segMRIpath - path to folder with segmented MRI files
%           - filter - not mandatory. It is possible to give the filter to
%                       be used in ft_sourceanalysis (usefull for common filter).
%           - recordFile - the file with the record. This is a mat file
%                       which is the output of "query" function.
%           - headModelType - the method used to creat head model.
%                        default: single sphere. only 'singlesphere' supported at the moment.
%           - fftcfg - config struct for freqAnalysisWrap. see freqAnalysisWrap
%                       for documentation.
%           - method - method for source localization.
%                       options: see ft_sourceanalysis.
%           - timeDomain - for eloreta method you must specify if source reconstruction is computer in the time-domain ('yes')
%              or in the frequency-domain ('no')
%
%   RETURN:
%       - source - a struct.... TODO: documentation 

    %TODO: input validation

    %set default head model type
    supportedHeadModelType = {'singlesphere'};
    if (~isfield(cfg,'headModelType') || ...
           ~find(strcmp(supportedHeadModelType, cfg.headModelType)))
           cfg.headModelType = 'singlesphere';
    end
    
    if (cfg.segMRIpath(end) ~= filesep)
        cfg.segMRIpath = [cfg.segMRIpath filesep];
    end
    
    filesSuffix = ['_' cfg.patientName '.mat'];
    
    %load electrode file. the name of the variable will be elec
    %the structure of electrodes is given in mm in the MNI coordinate
    %system.
    elec = load2struct([cfg.segMRIpath 'electrodes' filesep 'elec' filesSuffix]);
    elec = ft_convert_units(elec, 'cm'); %convert mm to cm
    
    %load subject's MNI grid
    %TODO: check that this is also in cm
    gridVar = load2struct([cfg.segMRIpath 'grids' filesep 'grid_' cfg.headModelType filesSuffix]); %gridVar is used beause otherwise the matlab function 'grid' causes problems
    
    % TODO: Roey added on 15.05.2014 to restrict source reconstruction to
    % outside of the cerrebellum
    gridVar = getRidOfCerrebellum([], gridVar);
    
    %load head model
    vol = load2struct([cfg.segMRIpath 'headmodel' filesep cfg.headModelType '_headmodel' filesSuffix]);
    
    %check if method is used in frequency domain (and not time domain)
    if strcmp(cfg.method, 'dics') | strcmp(cfg.method, 'lcmv')
        isFreqDomainMethod = 1;
    else
        isFreqDomainMethod = 0;
    end
    % The special case of eloreta, which can be either in time domain or in
    % frequency domain
    if strcmp(cfg.method, 'eloreta')
        if strcmp(cfg.timeDomain, 'yes')
            isFreqDomainMethod = 0;
        else
            isFreqDomainMethod = 1;
        end
    end
    
    %convert to frequency domain if necessary
    if isFreqDomainMethod
        fftRecord = freqAnalysisWrap(cfg.fftcfg, cfg.recordFile);
    end
       
    %perform source localization
    %TODO: do we want to add cfg.rawtrial?
    slcfg = struct;
    slcfg.method = cfg.method;
    slcfg.elec = elec;
    slcfg.grid = gridVar;
    slcfg.vol = vol;
    slcfg.rawtrial = 'yes';
    slcfg.hdmfile = [cfg.segMRIpath 'headmodel' filesep cfg.headModelType '_headmodel' filesSuffix];
    
    if isFreqDomainMethod 
        slcfg.frequency = fftRecord.freq; %The mean frequency in the foilim band
    end
    
    if (strcmp(cfg.method,'lcmv'))
        slcfg.lcmv.lambda = '5%';
        slcfg.lcmv.keeptrials = 'yes';
    end
    if (strcmp(cfg.method,'mne'))
        slcfg.mne.lambda = '5%';
    end
    
    if (isfield(cfg,'filter')) %use given filter if given
        slcfg.grid.filter = cfg.filter;
    else %if filter is not given compute it over all trials
        if (strcmp(cfg.method,'lcmv'))
            slcfg.lcmv.keepfilter = 'yes';
        end
        slcfg.keepfilter = 'yes';
        slcfg.rawtrial = 'no';
        slcfg.singletrial = 'no';
        slcfg.keeptrials = 'yes';

        if ~isFreqDomainMethod % if inverse solution method is in time domain
            timeDomainData = load2struct(cfg.recordFile); 
            % calculate the avg of each trial, for use in ft_sourceanalysis
            for trialI = 1:length(timeDomainData.trial)
                timeDomainData.avg(:,trialI) = mean(timeDomainData.trial{trialI}')';
            end
            source_for_filter = ft_sourceanalysis(slcfg, timeDomainData); %this source structure is used to compute the filter to be used later
        else % that is, if inverse solution method is in frequency domain
            source_for_filter = ft_sourceanalysis(slcfg, fftRecord); %this source structure is used to compute the filter to be used later
        end
            
            slcfg.grid.filter = source_for_filter.avg.filter;
    end

    % Compute inverse solution and don't keep the filter
    slcfg.keepfilter = 'no';
    slcfg.rawtrial = 'yes';
    
    if isFreqDomainMethod
        sources = ft_sourceanalysis(slcfg, fftRecord);
    else
        sources = ft_sourceanalysis(slcfg, timeDomainData); % ADDED BY ROEY TO CHECK TIME DOMAIN SOURCE RECONSTRUCTION USING ELORATE
    end
    
   % Add .dim and .pos to source structure according to: http://fieldtrip.fcdonders.nl/example/create_single-subject_grids_in_individual_head_space_that_are_all_aligned_in_mni_space
    templateGrid  = load2struct([cfg.segMRIpath 'grids' filesep 'grid_' cfg.headModelType filesSuffix]);%gridVar is used beause otherwise the matlab function 'grid' causes problems
    sources.dim = templateGrid.dim;
    sources.pos= templateGrid.pos;

end


