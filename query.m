function [flag] = query (names, inputDir, type, eyes, drugs, minTime, maxTime, split,noInterpolatedNeighbours,outputName)

% QUERY creates a Field Trip .mat file of all segments according to the
% given conditions.
%
% INPUT
% names - CELL - patients names (e.g.: pLT1997)
% inputDir - input directory where mat files are saved
% type - string -  R, BP, S, BS etc. A means all types
% eyes - string - O, C, U. A means all conditions
% drugs - string - CLEAN, TEGRATOL, DEPALEPT etc.  A means all types
% minTime, maxTime - min and max time (in seconds) of segments
% split - if split=1, the function splits longer segments to fit maxTime.
% outputName is the name of the data mat file to be saved (at inputDir\queries)
% noInterpolatedNeighbours - if noInterpolatedNeighbours=1, segments
% with interpolated neighbouring electrodes are discarded
%
% e.g: query({'pLT1997'}, 'C:\PNES', 'A', 'O', 'CLEAN|TEGRATOL',0.05,2,0, 'BSOpen')
% e.g: query({'pSN1993'}, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced', 'R', 'O', 'A', 0.05, 0.5, 1, 'RestOpen')
%
% query({'pSN1993','pEC1980','pGR1992','pLT1997','pSG1991','pSN1993','pSS1984'}, 'C:\Users\roeysc\Desktop\PNES\DB', 'R', 'C', 'A', 0.05, 2, 1, 'RestClosed')
% OUTPUT
% a Field Trip .mat file of all segments according to the conditions specified is saved at the inputDir\queries folder.

validEEGLabels = {'Fp1','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','O2'};    

if strcmp(type,'A')
    type = 'R|RT|BP|P|E|BE';
end

if strcmp(eyes,'A')
    eyes = 'C|O|U';
end    

if strcmp(drugs,'A')
    drugs = '[\w]';
end

if(inputDir(end)~='\')
    inputDir(end+1) = '\';
end

data = [];
data.label = validEEGLabels;
% Create list of neighbouring electrode pairs
% CHECKME: maybe we should define different neighbours
cfg_neighb = [];
cfg_neighb.method  = 'distance'; % CHECKME: consider using 'triangulation'
cfg_neighb.neighbourdist = 0.3; % since the sens is in units of dm. Default is 0.4
elecFile = which('elec1020.lay');
cfg_neighb.layout = elecFile;
neighbours = ft_prepare_neighbours(cfg_neighb, data);
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


% "data" is the function output
data=[];
data.label = validEEGLabels; % cell-array containing strings, Nchan X 1
data.fsample = []; % sampling frequency in Hz, single number
data.trial = [];
data.time = [];
data.interpolatedElectrodes = [];

for patientI = 1:length(names)
    
    patientName = names{patientI};
    fullPath = [inputDir, patientName, '.mat'];
    
    % Load patient's FieldTrip file
    if ~exist(fullPath, 'file')
        error(['Could not find file for patient ' patientName]);
    else
        patientData = load(fullPath);
    end
    
    % Add all relevant segments to "data"
    allConditionNames = fieldnames(patientData);
    for segmentI = 1:length(allConditionNames)
        conditionName = allConditionNames(segmentI);
        
        %check if condition is correct
        temp = regexpi( conditionName ,[ '^(' type ')_(', eyes, ')_[\d]*', drugs, '*$' ]);
        if(~isempty(temp{1}));
                        
            eval(  ['trialsNum  = length(  patientData.' conditionName{1}, '.trial  );']  )
            for trialI = 1:trialsNum
                
                eval(  ['trialTime = patientData.' conditionName{1}, '.time{trialI}(end);']  )
                
                if (noInterpolatedNeighbours == 1)
                        neighboursFlag = 0;
                        %check if two neighbouring electrodes were interpolated
                        eval(['interpolatedElectrodes =  patientData.' conditionName{1} '.interpolatedElectrodes{trialI};'] );

                        for elecI = 1:length(interpolatedElectrodes)-1
                            electrode = interpolatedElectrodes(elecI);
                            index = find(strcmp(validEEGLabels,electrode)); % elecI's index in the neighbours cell array

                            for elecIin = elecI+1:length(interpolatedElectrodes)

                                if(  ismember(interpolatedElectrodes(elecIin), neighbours(index).neighblabel)  )
                                 %if we interpolated a neighbouring electrode, dismiss this trial
                                    neighboursFlag = 1;
                                end                               
                                
                            end
                        end
                    if neighboursFlag == 1
                        continue;
                    end
                end
                
                %check if segment time is correct
                if (minTime <= trialTime && trialTime <= maxTime)
                            
                            eval( ['data.fsample = patientData.' conditionName{1} '.fsample;'] );
                                if ( maxTime < 1/data.fsample )
                                    error('maxTime is smaller than 1 over sample time');
                                end
                            eval( ['data.trial{end+1} = patientData.' conditionName{1} '.trial{trialI};'] );
                            eval( ['data.time{end+1} = patientData.' conditionName{1} '.time{trialI};'] );
                            if (noInterpolatedNeighbours == 1)
                                eval(['data.interpolatedElectrodes{end+1}=  patientData.' conditionName{1} '.interpolatedElectrodes{trialI};'] );
                            end
                elseif minTime <= trialTime && split == 1
                            
                            segmentsInTrial = floor(trialTime/maxTime);
                            for i=1:segmentsInTrial
                                eval( ['data.fsample = patientData.' conditionName{1} '.fsample;'] );
                                eval( ['freq = patientData.' conditionName{1} '.fsample;'] );
                                index = 1+(i-1)*maxTime*freq; % index of first cell in trial
                                eval( ['data.trial{end+1} = patientData.' conditionName{1} '.trial{trialI}(:,index:index+maxTime*freq-1);'] );
                                eval( ['data.time{end+1} = patientData.' conditionName{1} '.time{trialI}(1:length(data.trial{end}));'] ); % each trial time starts with 0
                                if (noInterpolatedNeighbours == 1)
                                    eval(['data.interpolatedElectrodes{end+1}=  patientData.' conditionName{1} '.interpolatedElectrodes{trialI};'] );
                                end
                            end
                            
                            
                end
                   
            end
            
        end
    end
        
end

% Save query's mat file
if ~exist([inputDir 'queries'], 'dir')
    mkdir(inputDir, 'queries')
end

% Delete old files
if exist([inputDir 'queries\', outputName '.mat'], 'file')
        delete([inputDir, 'queries\', outputName, '.mat']);
end

if isempty(data.trial)
    error('No segments found for the specified conditions!');
    flag = 0;
else
    save([inputDir, 'queries\', outputName, '.mat'], 'data');
    flag = 1;
end


end