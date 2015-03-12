function [freqAbs freqRel] = freqAbsRel(cfg, conditionPath)
% freqAbsRel returns the Absolute and Relative frequency structures of the condition
%
% INPUT
%   conditionPath: the full path of a condition structure as obtained from 'query.m' 
%   cfg.bands;
% OUTPUT
%   freqAbs: the absolute power of each electrode in each trial and each
%                       frequency band (subjected to square root, after
%                       http://www.sciencedirect.com/science/article/pii/00
%                       13469482901122#
%   freqRel: the relative power of each electrode in each trial and each
% %                       frequency band (
%
% NOTES: 1) The output structures are not standartized-normalized. This is done
%                    in a different code, to ensure standartization-normalization over all
%                    relevant segment, from all relevantconditions.
%                2) This code supports only 19 electrodes 1020-layout.
%                    Consider changing the elecFile (in line 43)
%                3) Consider changing cfg.analysistype ('smoothing' is now default)

%%
if (isfield(cfg,'bands'))
    bands = cfg.bands;
else
    bands = [1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48]; % These were used in Shahar's article
end

if (isfield(cfg,'analysistype'))
    analysistype = cfg.analysistype;
else
    analysistype = 'smoothing';
end

if (isfield(cfg,'sqroot'))
    sqroot= cfg.sqroot;
else
    sqroot = 'yes';
end

%% Load file and Configure cfg
file_content = load(conditionPath);
FieldNames = fieldnames(file_content);
conditionData = getfield(file_content,FieldNames{1}); 
sRate = conditionData.fsample;
trialLength = length( conditionData.trial{1} ) / sRate;

data = [];
data.trial = conditionData.trial;
data.time = conditionData.time;
data.fsample = conditionData.fsample;
data.label= conditionData.label;

%% Find neighbouring electrode pairs
% CHECKME: maybe we should define different neighbours
cfg_neighb = [];
cfg_neighb.method  = 'distance'; % CHECKME: consider using 'triangulation'
cfg_neighb.neighbourdist = 0.3; % since the sens is in units of dm. Default is 0.4
elecFile = which('elec1020.lay');
cfg_neighb.layout = elecFile;
neighbours  = ft_prepare_neighbours(cfg_neighb, data);

            %%% THESE 3 LINES ARE USED TO PLOT THE NEIGHBOURS. THE LAST TWO ARE USED TO
            %%% GET BACK THE GOOD ELECFILE
            % % % elecFile = which('elec1020Fixed.lay'); % In order to show neighbours graphically
            % % % cfg_neighb.layout = elecFile;
            % % % ft_neighbourplot(cfg_neighb, data);
            % % % elecFile = which('elec1020.lay');
            % % % cfg_neighb.layout = elecFile;

% Since the MCN system renames four points of the 10–20 system—T3, T4, T5
% and T6—asT7, T8, P7 and P8 respectively, we must check to see if
% all electrodes were used. If not, we have to performthe following fix:
if (size(neighbours ,2) ~= size(data.label,2))
    dataTemp = data;
    dataTemp.label =  {'Fp1','Fp2','F7','F3','Fz','F4','F8','T7','C3','Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2'}; % Valid EEG labels in MCN format
    cfg_neighb.layout = elecFile;
    neighbours  = ft_prepare_neighbours(cfg_neighb, dataTemp);
    for elecI = 1:size(neighbours,2)
        if strcmp(neighbours(elecI).label, 'T7')
            neighbours(elecI).label = 'T3';
        elseif strcmp(neighbours(elecI).label, 'T8')    
            neighbours(elecI).label = 'T4';
        elseif strcmp(neighbours(elecI).label, 'P7')    
            neighbours(elecI).label = 'T5';
        elseif strcmp(neighbours(elecI).label, 'P8')
            neighbours(elecI).label = 'T6';
        end
        for neighI = 1:size(neighbours(elecI).neighblabel,1)
            if strcmp(neighbours(elecI).neighblabel{neighI}, 'T7')
                neighbours(elecI).neighblabel{neighI} = 'T3';
            elseif strcmp(neighbours(elecI).neighblabel{neighI}, 'T8')
                neighbours(elecI).neighblabel{neighI} = 'T4';
            elseif strcmp(neighbours(elecI).neighblabel{neighI}, 'P7')
                neighbours(elecI).neighblabel{neighI} = 'T5';
            elseif strcmp(neighbours(elecI).neighblabel{neighI}, 'P8')
                neighbours(elecI).neighblabel{neighI} = 'T6';
            end        
        end
                
    end
end % of fixing electrodes
dataTemp = [];

%% For EACH ELECTRODE, go over all neighbours and create a temporary struct
% "dataTemp" and perform frequency analysis upon it
for elecI = 1:size(neighbours,2)
        dataTemp = data;       
        dataTemp.label = [];
        dataTemp.trial = [];
        for trialI = 1:size(data.trial,2) % clear all trials in dataTemp   
            dataTemp.trial{trialI} = [];
        end
        for neighbI = 1:size(neighbours(elecI).neighblabel,1) % run over all neighbours
            % Set dummy electrode labels to fit number of neighbours
            dataTemp.label{neighbI} = data.label{neighbI};
            % Insert the trials in bipolar monatge
            neighbElecI = find(strcmp(    data.label,  neighbours(elecI).neighblabel(neighbI)    )); % find neighbour's index in data.label list
            for trialI = 1:size(data.trial,2)
                dataTemp.trial{trialI} = [dataTemp.trial{trialI}; data.trial{trialI}(elecI,:) - data.trial{trialI}(neighbElecI,:) ];
            end
        end

        % Define cfg for freqAnalysisWrap
        cfg = [];
        cfg.output = 'pow';
        cfg.analysistype = analysistype; % 'maxperlen' (using mean) or default 'smoothing'
        cfg.foilim = []; % to be configured in forthcoming loop
        cfg.keeptrials = 'yes';
        cfg.isfile= 'no';
        % Perform frequency analysis on first band, and then add the power spectrum
        % (or other output) from all other bands

        if strcmp(cfg.analysistype, 'maxperlen')
            cfg.foilim = [ bands(1), bands(end) ];
            freq{elecI} =  freqAnalysisWrap(cfg, dataTemp);    
        elseif strcmp(cfg.analysistype, 'smoothing')
            cfg.foilim = bands(1,:);
            freq{elecI} =  freqAnalysisWrap(cfg, dataTemp);    % CHECKME (really, just check me)

            for bandI = 2:size(bands,1);
                cfg.foilim = bands(bandI,:);
                freqTemp = freqAnalysisWrap(cfg, dataTemp);         
                freq{elecI}.powspctrm(:,:,bandI) = freqTemp.powspctrm;    

                freq{elecI}.freq= [freq{elecI}.freq freqTemp.freq]; % in the smoothing option "freq" holds the center of each frequency band
            end
        else
            error('the cfg.analysistype you specified is not supported');
        end
end % of electrodes loop

%% Create a structure base for the freqAbs and freqRel structures
        if strcmp(cfg.analysistype, 'maxperlen')
            cfg.foilim = [ bands(1), bands(end) ];
            freqAbs =  freqAnalysisWrap(cfg, data);
        elseif strcmp(cfg.analysistype, 'smoothing')
            cfg.foilim = bands(1,:);
            freqAbs =  freqAnalysisWrap(cfg, data);

            for bandI = 2:size(bands,1);
                cfg.foilim = bands(bandI,:);
                freqTemp = freqAnalysisWrap(cfg, data);         
                freqAbs.powspctrm(:,:,bandI) = freqTemp.powspctrm;    
                
                freqAbs.freq= [freqAbs.freq freqTemp.freq]; % in the smoothing option "freq" holds the center of each frequency band
            end
        else
            error('the cfg.analysistype you specified is not supported');
        end
                    
%% Use "freq" to calculate freqAbs
% Now the freqAbs (and freqRel)  power spectrum is: TRIAL   X  ELECTRODE  X  BAND
% and the same goes for each cell in "freq"
for elecI = 1:size(freqAbs.powspctrm,2)
    freqAbs.powspctrm(:,elecI,:) = mean(    freq{elecI}.powspctrm , 2  ); % Take the mean over "electrodes" (neighbouring bipolar channels)
end

% The Square Root is taken after averaging, like here:
% http://www.sciencedirect.com/science/article/pii/S0013469498000923
if (strcmp(sqroot,'yes'))
    freqAbs.powspctrm = sqrt(freqAbs.powspctrm);
end

%% Use freqAbs to calculate freqRel
% For each electrode, sum over all powers in all frequency bands
% and divide by that sum
freqRel = freqAbs;
for elecI = 1:size(freqAbs.powspctrm,2)
    freqSum = sum(    freqRel.powspctrm(:,elecI,:) , 3  ); % Power sum of each trial in elecI over all frequency bands
    freqSum = repmat(freqSum, 1, size(freqRel.powspctrm,3));
    freqRel.powspctrm(:,elecI,:) = squeeze( freqRel.powspctrm(:,elecI,:) ) ./  freqSum;
end

%% Normalization is performed outside this function, to allow
% for normalization over all segments in all conditions

end