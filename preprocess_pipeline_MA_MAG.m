%% Preprocessing Pipeline
% After applying massConvertTRC2MAT and then createDB_revised, you can
% start with the pipeline.
% Make sure EEGLab is not present in Matlab path, since this causes
% problems in filtering due to a clash in signal processing functions.

ft_defaults;
close all; clear; clc

%% Convert from the trc2mat format to the fieldtrip rawdata format.
cfg = [];
cfg.continuous = 'no';
% rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\forISCheckRoeyEEG\Roey\pRoey.mat');
% rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pWA1993\pWA1993.mat');
% rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pSG1991\pSG1991_just_N.mat');
% rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pGA_LI.mat');
rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pMA_MAG.mat');


% Remove the ECG+ channel
% TODO: it could have been nice to save the ECG1+ channel seperately to
% check for ECG artifacts, but this causes problems since some trials have
% this channel and others don't.

temp = rawData;
cfg = [];
cfg.channel = rawData.label( ~strcmp(rawData.label, 'ECG1+') );
rawData = ft_preprocessing(cfg, rawData);
rawData.trialtype = temp.trialtype;
rawData.interpolatedElectrodes = temp.interpolatedElectrodes;
rawData.trialStartTime = temp.trialStartTime;
clear temp;

% Browse data to see what you're dealing with
cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
% cfg.channel = {'Fp1', 'Fp2', 'C3', 'C4', 'O1', 'O2'};
cfg.blocksize = 10;
cfg.trl = 2;
cfg.viewmode = 'vertical';
cfg.plotlabels = 'yes'; % this doesn't work on some matlab versions

ft_databrowser(cfg, rawData)

%% Filter
cfg = [];
cfg.channel = 'all';
cfg.reref = 'no';
cfg.lpfilter = 'yes';
    cfg.lpfreq = 40;
cfg.hpfilter = 'yes';
    cfg.hpfreq = 1;
cfg.dftfilt = 'yes'; % no need to filter out line noise (50Hz) because the lpfreq is 50Hz.
% if line noise is still evident, see:
% http://fieldtrip.fcdonders.nl/faq/why_is_there_a_residual_50hz_line-noise_component_after_applying_a_dft_filter

filteredData = rereference_and_filter(cfg, rawData);

% % Compare the first electrode in the first trial and browse data
% figure
% plot(rawData.time{1}, rawData.trial{1}(1,:))
% hold all
% plot(filteredData.time{1}, filteredData.trial{1}(1,:),'lineWidth', 2)
% xlabel('time (s)')
% legend('raw','filt')


cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';

% cfg.channel = {'F4', 'F8', 'T7', 'C3', 'Cz'};
% cfg.channel = {'Fp1', 'Fp2', 'C3', 'C4', 'O1', 'O2'};
% cfg.blocksize = 10;
% cfg.trl = 2;
    
ft_databrowser(cfg, filteredData)
% 
% Add electrodes to interpolate if necessary

temp = {'Fp1',[];
        'Fp2',[];
        'F7', [];
        'F3', [];
        'Fz', [];
        'F4', [];
        'F8', [];
        'T7', [];
        'C3', [];
        'Cz', [];
        'C4', [];
        'T8', [];
        'P7', [];
        'P3', [1:25 32:36 40:51 56:60 62:68 70:75];
        'Pz', [1:4 8];
        'P4', [];
        'P8', [];
        'O1', [5 8 62:68 70:75];
        'O2', []};
   
for i = 1:size(temp,1) % i goes over all electrodes
    for j = 1:length(temp{i,2}) % j goes over all wanted trials
        filteredData.interpolatedElectrodes{temp{i,2}(j)} = [filteredData.interpolatedElectrodes{temp{i,2}(j)}, temp{i,1}];
    end
end

%% Get rid of trials with too many interpolations
filteredData.elec = ft_read_sens(fullfile('standard_1020.elc'));
filteredData.elec = reorder_electrodes(filteredData.elec, filteredData.label);
filteredData.elec = ft_convert_units(filteredData.elec, 'cm');

cfg_neighb = [];
cfg_neighb.method  = 'distance';
cfg_neighb.layout = 'lab_quickcap64_mcn_no_cb.mat';
cfg_neighb.neighbourdist = 9;% maximum distance (in cm) between neighbouring electrodes
                             % recommended for 64 cap: 5.5
                             % recommended for 19 electrodes: 10
cfg_neighb.elec = filteredData.elec;
neighboursStruct = ft_prepare_neighbours(cfg_neighb, filteredData);

good_trials = 1:length(filteredData.trial); % these will be correct after to loops

bad_trials = [];
cfg = [];
cfg.neighboursStruct = neighboursStruct;
for trialI = 1:length(filteredData.trial)
    if isElectrodesNeighbours( cfg, filteredData.interpolatedElectrodes{trialI} )
        bad_trials(end+1) = trialI;
    end
end
good_trials = good_trials(~ismember(good_trials,bad_trials))

cfg = [];   
temp = 1:length(filteredData.trial);
cfg.trialindices = temp(~ismember(temp,bad_trials));
filteredData = getTrials(cfg, filteredData);

%% Interpolate
% The electrodes that need to be interpolated in each trial are saved in
% the field interpolatedElectrodes, 
% This is done before rereferencing in order avoid noisy electrodes messing
% up all other electrodes.

cfg.plot = 'yes';
cfg.elecFile = fullfile('standard_1020.elc');
cfg.layout = fullfile(which('lab_quickcap64_mcn_no_cb.mat'));
interpolatedData = interpolate_electrodes(cfg, filteredData);

% Browse data to see if interpolation worked properly.
cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';

ft_databrowser(cfg, interpolatedData)

%% Change to bipolar montage (double banana)
cfg = [];

bipolar.labelorg  = {'Fp1','Fp2','F7','F3','Fz','F4','F8','T7','C3','Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2'};
bipolar.labelnew  = {'F4-Fp2','C4-F4','P4-C4','O2-P4','F3-Fp1','C3-F3','P3-C3','O1-P3','F8-Fp2','T8-F8','P8-T8','O2-P8','F7-Fp1','T7-F7','P7-T7','O1-P7','Cz-Fz','Pz-Cz'}; % 19_electrodes_bipolar_montage2.xlsx

% bipolar.labelnew  =
% {'Fp1-F7','F7-T7','T7-P7','P7-O1','Fp1-F3','F3-C3','C3-P3','P3-O1','Fp2-F8','F8-T8','T8-P8','P8-O2','Fp2-F4','F4-C4','C4-P4','P4-O2','Fz-Cz','Cz-Pz'}; % 19_electrodes_bipolar_montage.xlsx


[~, ~, bipolar.tra] = xlsread(fullfile(which('19_electrodes_bipolar_montage2.xlsx')));
bipolar.tra(1,:) = [];

bipolar.tra = cell2mat(bipolar.tra);

cfg.montage = bipolar;


interpolatedDataBipolar = ft_preprocessing(cfg, interpolatedData);

interpolatedDataBipolar.trialtype = interpolatedData.trialtype;
interpolatedDataBipolar.interpolatedElectrodes = interpolatedData.interpolatedElectrodes;

% Browse data
cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';
cfg.plotlabels = 'yes'; % this doesn't work on some matlab versions
cfg.blocksize = 10;

ft_databrowser(cfg, interpolatedDataBipolar)

%% Rereference
cfg = [];
cfg.reref = 'yes';
cfg.refchannel = 'all';% interpolatedData.label(1:end-1); % don't use the ECG+ electrode OR 'all'
cfg.channel = 'all'; %interpolatedData.label(1:end-1); % don't use the ECG+ electrode OR 'all'

rereferencedData = rereference_and_filter(cfg, interpolatedData);

% Browse data
cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';

% cfg.blocksize = 10;
% cfg.channel = {'Fp1', 'Fp2', 'C3', 'C4', 'O1', 'O2'};

ft_databrowser(cfg, rereferencedData)

%% If possible, reject electrode pops before ICA
% (see http://fieldtrip.fcdonders.nl/tutorial/automatic_artifact_rejection)
% fix: 4, 5, 14, 15, 17, 19, 20
cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.comscaple = 'local';
cfg.viewmode = 'vertical';
cfg.channel = 'all';

bad_segmants = ft_databrowser(cfg, rereferencedData);

rereferencedDataOld = rereferencedData;

cfg=[];
cfg.artfctdef.reject = 'partial'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
cfg.artfctdef.visual.artifact = bad_segmants.artfctdef.visual.artifact; % 
rereferencedData = ft_rejectartifact(cfg,rereferencedData);

% % % FIXME: now we have to add the interpolated electrodes field, the
% % % trialsStartTime field, and the trialtype field.
% % % if no trials were cut, we can use:
rereferencedData.trialtype  = interpolatedData.trialtype ; 
rereferencedData.trialStartTime = interpolatedData.trialStartTime; 
rereferencedData.interpolatedElectrodes = interpolatedData.interpolatedElectrodes; 
rereferencedData.elec = interpolatedData.elec; 

% % %

cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.comscaple = 'local';
cfg.viewmode = 'vertical';
cfg.channel = 'all';

ft_databrowser(cfg, rereferencedData);

%% ICA artifact detection
% Here you should mark all artifacts. They will be saves to _____.
cfg = [];
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
cfg.numcomponent = length(rereferencedData.label)-4; % This should be the number of electrodes minus 1 (because of average referencing,
%                                                      minus the maximum number of interpolated electrodes in a trial.
cfg.demean = 'yes';
% cfg.channel = rereferencedData.label(1:end-1); % in case there's a ECG+ electrode we don't want to use
cfg.trials = [1 2 7 18 55 56]; % it is best to perform the analysis on trials with artifacts
comp = ft_componentanalysis(cfg, rereferencedData);


% Identify the artifacts
% Very important is to know that on subsequent evaluations of the component decomposition result in components that can have a different order.
% That means that component numbers that you write down do not apply to another run of the ICA decomposition on the same data.
% plot the components for visual inspection
figure
numcomponent = cfg.numcomponent;
cfg = [];
cfg.component = [1:numcomponent];        % specify the component(s) that should be plotted
cfg.layout    = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)

cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.comscaple = 'local';
cfg.viewmode = 'component';
cfg.channel = 'all';

artifacts_segments = ft_databrowser(cfg, comp);

% Artifact segments will now be in "artifacts_segments.artfctdef.visual.artifact"
% You can rerun ft_databrowser with artifacts_cfg, and artifact be shown.

%% Watch all the data in the components space
cfg = [];
cfg.unmixing  = comp.unmixing;
cfg.topolabel = comp.topolabel;
comp_all = ft_componentanalysis(cfg, rereferencedData);

cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.comscaple = 'local';
cfg.viewmode = 'component';
cfg.channel = 'all';

artifacts_segments = ft_databrowser(cfg, comp_all);

%% Remove the bad components and backproject the data
cfg = [];
cfg.component = [11 14]; % components to be removed
postIcaData = ft_rejectcomponent(cfg, comp, rereferencedData);

figure
plot(rereferencedData.time{1}, rereferencedData.trial{1}(1,:))
hold on
plot(postIcaData.time{1}, postIcaData.trial{1}(1,:), 'r')
xlabel('time (s)')
legend('Pre ICA','Post ICA')

% Browse data
cfg = [];
cfg.layout = 'lab_quickcap64_mcn_no_cb.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'vertical';

cfg.blocksize = 10;
cfg.channel = 'all';
ft_databrowser(cfg, postIcaData)

%% Save the data
save('C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\post ICA\pMA_MAG_post_ICA.mat', 'postIcaData')

%% Now you can continue analyzing the data on trials of specific conditions using getTrials.
% The trial types in the data can be seen using

load('C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\post ICA\pMA_MAG_post_ICA.mat')

trialTypes = unique(postIcaData.trialtype)
% trialTypes = trialTypes([1;3]); %take only closed eyes

cfg = [];
cfg.minlength = 10;
cfg.maxlength = 10;
cfg.segmenttrials = 'yes';

for i = 1:length(trialTypes)
    cfg.trialtypes = trialTypes(i);
    
    eval([trialTypes{i} '_trials = getTrials(cfg, postIcaData);']);
end


%%

PsTimes = cell2mat(P_O_CLEAN_trials.trialStartTime);
RestTimes = cell2mat(R_O_CLEAN_trials.trialStartTime);

PsTimesSeconds = (PsTimes - PsTimes(1))*3600*24
RestTimesSeconds = (RestTimes - RestTimes(1))*3600*24

% indices = getTrialsIndicesSubset(PsTimes,RestTimes);
% indices = randperm(length(R_C_CLEAN_trials.trial));
% indices = indices(1:length(P_C_CLEAN_trials.trial));
indices = [2:5, 13:16];


RestTrials = R_O_CLEAN_trials;
RestTrials.trial = RestTrials.trial(indices);
RestTrials.time = RestTrials.time(indices);
RestTrials.trialtype = RestTrials.trialtype(indices);
RestTrials.interpolatedElectrodes = RestTrials.interpolatedElectrodes(indices);
RestTrials.trialStartTime = RestTrials.trialStartTime(indices);
RestTrials.sampleinfo = RestTrials.sampleinfo(indices ,:); 

PsTrials = P_O_CLEAN_trials;