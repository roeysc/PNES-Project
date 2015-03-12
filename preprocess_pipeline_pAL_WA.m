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
% rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\_forISCheckRoeyEEG\Roey\pRoey.mat');
% rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pWA1993\pWA1993.mat');
% rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pSG1991\pSG1991_just_N.mat');
rawData = mat2rawdata(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pDA_MA.mat');


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
cfg.lpfreq = 48;
cfg.hpfilter = 'yes';
cfg.hpfreq = 1;
cfg.dftfilt = 'yes'; % no need to filter out line noise (50Hz) because the lpfreq is 50Hz.

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
trials = [12:14, 16:17, 27, 31, 33, 35, 49]; % 32:34
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'O1'}];
end

trials = [1:8, 10, 13:15, 17, 36, 49, 51];
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'O2'}];
end

trials = [9:11, 13:16, 21, 23, 28:29, 34, 43, 45]; % 17:21, 24:25, 27, 30
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'Fp1'}];
end

trials = [9:11, 13, 17, 18, 28:29, 34, 42:43, 45, 47, 51];  % 17:21, 24:25, 30
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'Fp2'}];
end

trials = [3:6, 9, 12, 13, 16, 35:36, 39:45];
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'P7'}];
end


trials = [2];
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'F7'}];
end

trials = [27, 47];
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'F8'}];
end


trials = [4, 16, 31], 36;
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'P8'}];
end


trials = [2, 3, 5:8, 11, 13, 31, 34, 48];
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'T7'}];
end


trials = [4, 16, 33, 45:46, 51];
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'T8'}];
end

trials = [36];
for i = 1:length(trials)
    filteredData.interpolatedElectrodes{trials(i)} = [filteredData.interpolatedElectrodes{trials(i)}, {'P4'}];
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

%% ICA artifact detection
% Here you should mark all artifacts. They will be saves to _____.
cfg = [];
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
cfg.numcomponent = length(rereferencedData.label)-4; % This should be the number of electrodes minus 1 (because of average referencing,
%                                                      minus the maximum number of interpolated electrodes in a trial.
cfg.demean = 'yes';
% cfg.channel = rereferencedData.label(1:end-1); % in case there's a ECG+ electrode we don't want to use
cfg.trials = [1 9 10 11 12]; % it is best to perform the analysis on trials with artifacts
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
cfg.component = [3, 9]; % components to be removed
postIcaData = ft_rejectcomponent(cfg, comp, rereferencedData)

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
save('C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\post ICA\pAL_WA_post_ICA.mat', 'postIcaData')

%% Now you can continue analyzing the data on trials of specific conditions using getTrials.
% The trial types in the data can be seen using

load('C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\post ICA\pDA_MA_post_ICA.mat')

trialTypes = unique(postIcaData.trialtype)

cfg = [];
cfg.minlength = 10;
cfg.maxlength = 10;
cfg.segmenttrials = 'yes';

for i = 1:length(trialTypes)
    cfg.trialtypes = trialTypes(i);
    
    eval([trialTypes{i} '_trials = getTrials(cfg, postIcaData);']);
end


%%

PsTimes = cell2mat(P_C_CLEAN_trials.trialStartTime);
RestTimes = cell2mat(R_C_CLEAN_trials.trialStartTime);

indices = getTrialsIndicesSubset(PsTimes,RestTimes);
indices = randperm(21);
indices = indices(1:length(P_C_CLEAN_trials.trial));

RestTrials3 = R_C_CLEAN_trials;
RestTrials3.trial = RestTrials3.trial(indices );
RestTrials3.time = RestTrials3.time(indices );
RestTrials3.trialtype = RestTrials3.trialtype(indices );
RestTrials3.interpolatedElectrodes = RestTrials3.interpolatedElectrodes(indices );
RestTrials3.trialStartTime = RestTrials3.trialStartTime(indices );
RestTrials3.sampleinfo = RestTrials3.sampleinfo(indices ,:); 
