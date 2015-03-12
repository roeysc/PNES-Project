function [ sources ] = sourceAnalysisBem( cfg )
%Performs source analysis using ft_sourceanalysis for specific record
%   INPUT:
%       - cfg: configuration struct with the following fields:
%           - patientName - name of patient. If template MRI is used, use the name "single_subj_T1"
%           - segMRIpath - path to folder with segmented MRI files
%           - filter - not mandatory. It is possible to give the filter to
%                       be used in ft_sourceanalysis (usefull for common filter).
%           - recordStruct - the EEG record structure.
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

    if (cfg.segMRIpath(end) ~= filesep)
        cfg.segMRIpath = [cfg.segMRIpath filesep];
    end
    
    filesSuffix = ['_' cfg.patientName '.mat'];
    
    %load electrode file. the name of the variable will be elec
    %the structure of electrodes is given in mm in the MNI coordinate
    %system.
    elec = cfg.recordStruct.elec;
    
% % %     % If no electrodes are available in the struct, use:
% % %     elec = ft_read_sens(fullfile(which('standard_1020.elc')));
% % %     elec = ft_convert_units(elec, 'cm'); %convert mm to cm
    
    %load head model
    hdmfile = fullfile(which('standard_bem.mat')); % TODO: maybe we should use cortex_5124.surf.gii?
    vol = load2struct(hdmfile);
      
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    %load subject's MNI grid
    %TODO: check that this is also in cm
    gridcfg = [];
    gridcfg.grid.xgrid = -20:1:20;
    gridcfg.grid.ygrid = -20:1:20;
    gridcfg.grid.zgrid = -20:1:20;
    gridcfg.grid.unit = 'cm';
    gridcfg.grid.tight = 'yes';
    gridcfg.inwardshift = -1.5;
    gridcfg.vol = vol;

    gridVar = ft_prepare_sourcemodel(gridcfg);

    % TODO: Roey added on 15.05.2014 to restrict source reconstruction to
    % outside of the cerrebellum
    gridVar = getRidOfCerrebellum([], gridVar);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    
    %check if method is used in frequency domain (and not time domain)
    if strcmp(cfg.method, 'dics') || strcmp(cfg.method, 'lcmv')
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
    % TODO: this is the old format of using query. This should be changed
    % to use the new fieldtrip compatible data format.
    if isFreqDomainMethod
        fftRecord = freqAnalysisWrap(cfg.fftcfg, cfg.recordFile);
    end
       
    %perform source localization
    %TODO: do we want to add cfg.rawtrial?
    slcfg = struct;
    slcfg.method = cfg.method;

    

    
    % This used to be: slcfg.elec = elec; but if the data itself has
    % elec, we better use it
    slcfg.elec = cfg.recordStruct.elec;
       
    slcfg.grid = gridVar;
    slcfg.vol = vol;
    slcfg.rawtrial = 'yes';
    slcfg.hdmfile = hdmfile;

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
            slcfg.rawtrial = 'no'; % this is because we are now just computing the spatial filter
            slcfg.singletrial = 'no';
            slcfg.keeptrials = 'yes';

        if ~isFreqDomainMethod % if inverse solution method is in time domain
            timeDomainData = cfg.recordStruct; 
            % calculate the avg of each trial, for use in ft_sourceanalysis
            for trialI = 1:length(timeDomainData.trial)
                timeDomainData.avg(:,trialI) = mean(timeDomainData.trial{trialI}')';
            end
            
            % TODO: assumeing identity matrix covariance
%             timeDomainData.cov = [];
%             for i = 1:size(timeDomainData.trial,2)
%                 timeDomainData.cov(i,:,:) = eye(size(timeDomainData.label, 1));
%             end
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
    sources.dim = gridVar.dim;
    sources.pos = gridVar.pos;

end


