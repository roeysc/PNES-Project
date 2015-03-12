function createDB_revised(cfg, inputDir)
% function createDB_revised
% Description: This function creates a database of EEG records.
%
% Input: inputDir - path to the main directory (where Excel files are)
%
% cfg.validEegLabels: cell array of EEG channels labels to keep in data
%                     OR string path to txt file with these labels
%                     OR string path to layout file with channels to keep (.lay or .mat, as in "\fieldtrip-20140720\template\layout")
%
% Output: None. In each patient directory, creates a matlab file which
% contains all the processed segments.
%
% e.g.
% cfg = [];
% create_lab_quickcap64_mcn_no_cb;
% cfg.validEegLabels = which('lab_quickcap64_mcn_no_cb.mat');
% createDB_revised(cfg, 'C:\Users\Roey\Documents\ICNC\Neuropsychiatry Course\Greg EEG\PAT_1');%'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pSG1991')
% createDB_revised(cfg, 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\need to createDB YA_ME');%'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments\pSG1991')

% Initialize and load constants from createDB_constants.m
pathdef;
ft_defaults;
createDB_constants
[~, ~, electrodesConversionMap] = xlsread(fullfile(which('lab_electrodes_to_mcn_map.xlsx')));

% validEegChannels = getValidEegLabels(cfg.validEegLabels);
% validEegChannels = getValidEegLabels({'Fp1','Fpz','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','Oz','O2','c5a','c6a','cza','f4a','a1','f3a','a2','c3a','f5','c1a','f1','c2a','f2','c4a','f6','c5','t4l','c1','p5','c2','p1','c6','p2','t3l','p6','tcp1','ob1','c3p','p3p','c1p','p1p','pza','pzp','c2p','p2p','c4p','p4p','tcp2','ob2'});%(cfg.validEegLabels);
validEegChannels = getValidEegLabels({'Fp1','Fp2','F7','F3','Fz','F4','F8','T7','C3','Cz','C4','T8','P7','P3','Pz','P4','P8','O1','O2', 'ECG1+', 'ECG1-'});
% validEegChannels = getValidEegLabels('C:\Users\Roey\Documents\MATLAB\fieldtrip-20140720\template\layout\elec1020.lay');


% Backslah fix
if (inputDir(end) ~= filesep)
    inputDir(end+1) = filesep;
end

subDirs = dir(inputDir);

% Each patient has its own sub directory
for i=1:length(subDirs)

    % Skip non-directories
    if ((~(subDirs(i).isdir))||(strcmp(subDirs(i).name,'.'))||(strcmp(subDirs(i).name,'..')))
        continue;
    end
    
    % Delete patient's file if exists
    if exist([inputDir subDirs(i).name '.mat'], 'file')
        warning(['File ' subDirs(i).name '.mat exists. FILE WILL BE DELETED. Press ctrl+c to cancel']);
        pause();
        delete([inputDir subDirs(i).name '.mat']);
    end
    
    % Load patient's Excel file if exists
    if exist([inputDir subDirs(i).name '.xlsx'], 'file')
        [~,~,xlsPatient] = xlsread([inputDir subDirs(i).name '.xlsx']);
        interpolateSection = xlsPatient(titlesRow+1:end,interpolationColumn);
        timeFrom = xlsPatient(titlesRow+1:end,timeFromColumn);
        timeEnd  = xlsPatient(titlesRow+1:end,timeEndColumn);
        drugs = xlsPatient(titlesRow+1:end,drugsColumn);
    else
        warning(['No xlsx file for ', subDirs(i).name ,'. Assuming no interpolations, drugs etc.']);
        interpolateSection = [];
        timeFrom = [];
        timeEnd  = [];
        drugs = [];
    end
    
    % Find and load all recording files in current sub directory
    recordingFilesInSubDir = dir([inputDir subDirs(i).name '\*.TRC.mat']);
    segmentsCell = {};
    
    for j=1:length(recordingFilesInSubDir)
 
        recordingFilesInSubDir(j).name % Diaplay the TRC file name
        recordingFilesInSubDir(j).name = recordingFilesInSubDir(j).name(1:end-4);
        
        % Load recordings' files (EEG signal, markers file, recording time)
        eeg = load(fullfile( inputDir, subDirs(i).name, [recordingFilesInSubDir(j).name, '.mat'] ));
        
        mrkFile = fopen(fullfile( inputDir, subDirs(i).name, [recordingFilesInSubDir(j).name, '.mrk'] ),'r');
            eeg.mrk = textscan(mrkFile, '%s %s %s');
        fclose(mrkFile);
        for markerI = 1:length(eeg.mrk{3})
            indices = (eeg.mrk{3}{markerI} == '"');
            eeg.mrk{3}{markerI}(indices) = [];
        end
        
        % Convert electrodes name to standard form (MCN: T3->T7, T4->T8 etc)
        tmpcfg = [];
        tmpcfg.electrodesConversionMap = electrodesConversionMap;
        eeg.chan = convert_electrodes_to_mcn(tmpcfg, eeg.chan);
        
        eegTime = load(fullfile( inputDir, subDirs(i).name, [recordingFilesInSubDir(j).name, '.TIME.mat'] )); % eegTime has two columns, and the
        % number of rows is the number of recording parts in the TRC file (sometimes there's a stop and re-recording in the same file, marked as
        % "* * * Part 1 * * *" in Micromed. The 1st column is the sample number where there was a stop (or where the recording started, if it is 
        % equal to 0). The 2nd column is the real time of that sample. This file is created in "readtrc.m".
        
        
        % matlab 2009b has problems with creating the channels as strings array
        % with different sizes. Hence the following condition, using different formats of eeg.chan
        % as recieved from autotrc2mat:
        if strcmp(version('-release'),'2009b')
                for temp = 1: length(eeg.chan)
                    validChannelsIndices(temp) = ismember(eeg.chan{temp},validEegChannels);
                end
        else
                validChannelsIndices = ismember(lower(eeg.chan),lower(validEegChannels));
        end

        eeg.sig = eeg.sig(validChannelsIndices,:);
        eeg.chan = eeg.chan(validChannelsIndices);     
        
        segmentsCell = splitByMarker(eeg, segmentsCell, 'RS|PS|BPS|BES', eegTime);
        
        % Add a field for each segment, indicating the electrodes that need interpolation
        segmentsCell = addInterpolationList(segmentsCell, interpolateSection, eegTime, timeFrom, timeEnd, eeg.srate, electrodesConversionMap);
        segmentsCell = addDrugsList(segmentsCell, eegTime, drugs);
        
        saveSegments(segmentsCell, inputDir, subDirs(i).name, eeg.chan, eeg.srate, eegTime)
    end
    
end

end



%%%%%%%%%%%%%%%%%%%%%    AUXILIARY FUNCTIONS    %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function validEegLabels = getValidEegLabels(validEegLabels)
% validEegLabels returns a cell array of strings with the EEG labels that
% will be used among all those available in the record file.

    if iscell(validEegLabels)
        % do nothing

    elseif regexpi(validEegLabels, '.txt$')
        fileID = fopen(validEegLabels);
        validEegLabels = textscan(fileID, '%s');
        fclose(fileID);
        validEegLabels = validEegLabels{1}';
    
    elseif regexpi(validEegLabels, '.lay$')
        fileID = fopen(validEegLabels);
        validEegLabels = textscan(fileID, '%s');
        fclose(fileID);
        validEegLabels = validEegLabels{1}';
        validEegLabels = validEegLabels(6:6:end);
        
    elseif regexpi(validEegLabels, '.mat$')
        lay = load2struct(validEegLabels);
        validEegLabels = (lay.label)';    
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function segmentsCell = splitByMarker(eeg, segmentsCell, validMarkersStart, eegTime)
% splitByMarker splits the signal in eeg.sig by the the valid markers in eeg.mrk
% and returns the split segments in segmentsCell.
% 
% Valid markers are of the form '$S|E_O|U|C_#' where $ is a string and # is a number.
% Only the first part of the valid markers is needed, e.g.:
% validMarkersStart = 'RS|MHRS|MHLS|MLRS|MLLS|SHRS|SHLS|SARS|SALS|SLRS|SLLS|SMS|MUSICS|VISUALS'

createDB_constants

% Fix NC to C, NU to U etc (N was used to mark New long segments in Roey's project)
for markerI = 1:length(eeg.mrk{markerNameColumn})
    temp = regexpi(eeg.mrk{markerNameColumn}{markerI}, 'NO');
    if ~isempty(temp)
        eeg.mrk{markerNameColumn}{markerI}(temp:temp+1) = 'O';
    end
    temp = regexpi(eeg.mrk{markerNameColumn}{markerI}, 'NU');
    if ~isempty(temp)
        eeg.mrk{markerNameColumn}{markerI}(temp:temp+1) = 'U';
    end
    temp = regexpi(eeg.mrk{markerNameColumn}{markerI}, 'NC');
    if ~isempty(temp)
        eeg.mrk{markerNameColumn}{markerI}(temp:temp+1) = 'C';
    end
    temp = regexpi(eeg.mrk{markerNameColumn}{markerI}, 'ON');
    if ~isempty(temp)
        eeg.mrk{markerNameColumn}{markerI}(temp:temp+1) = 'O';
    end
    temp = regexpi(eeg.mrk{markerNameColumn}{markerI}, 'UN');
    if ~isempty(temp)
        eeg.mrk{markerNameColumn}{markerI}(temp:temp+1) = 'U';
    end
    temp = regexpi(eeg.mrk{markerNameColumn}{markerI}, 'CN');
    if ~isempty(temp)
        eeg.mrk{markerNameColumn}{markerI}(temp:temp+1) = 'C';
    end
end
    
for markerI = 1:length(eeg.mrk{markerNameColumn})

    eeg.mrk{markerNameColumn}{markerI}
    
    prefix = [];
    infix = [];
    if(~all(isempty(regexpi(eeg.mrk{markerNameColumn}{markerI},['^(' validMarkersStart ')_(U|O|C)_[\d]*[*]*'])))) % TODO: what happened to $?
        disp('Marker found!');
        eeg.mrk{markerNameColumn}{markerI}
        
        numberSTR = (regexpi(eeg.mrk{markerNameColumn}{markerI},'[\d]*','match')); % take the number written in the marker. e.g: '1' in 'BPS_O_1'
        starSTR = cell2mat(regexpi(eeg.mrk{markerNameColumn}{markerI},'[*]*','match'));
        currentStartSampleNumber = str2num(eeg.mrk{markerSampleColumn}{markerI});
        markerTypeS = regexpi(eeg.mrk{markerNameColumn}{markerI},['(' validMarkersStart ')'],'match');
        markerTypeE = [markerTypeS{1}(1:end-1) 'E'];
        
        for coMarkerI = markerI+1:length(eeg.mrk{markerNameColumn})
            if(~all(isempty(regexpi(eeg.mrk{markerNameColumn}{coMarkerI},cell2mat(['^' markerTypeE '_(U|O|C)_' numberSTR starSTR]))))) % TODO: and what happened to the $ here?
                disp('Corresponding marker was found');
                eeg.mrk{markerNameColumn}{coMarkerI}
                
                currentEndSampleNumber = str2num(eeg.mrk{markerSampleColumn}{coMarkerI});
                
                segment = eeg.sig(:,currentStartSampleNumber:currentEndSampleNumber);
                
                prefix = markerTypeS{1}(1:end-1);
                infix = regexpi(eeg.mrk{markerNameColumn}{coMarkerI},['_[\w]*_'],'match');
                infix = infix{1}(2:end-1); % remove '_'
                
                postfix = 'CLEAN';
                interpolatedElectrodes = {'NONE'};
                
                %%%%%%%%%%%%%%%%%%%%%%%%%
                % Calculate the serial time of the segments' start point
                index = find( eegTime.segmentsTime(:,1) <= currentStartSampleNumber );
                    index = index(end);
                timeAfterPause = eegTime.segmentsTime(index,2);
                currentSegmentStartinSerial = timeAfterPause + (currentStartSampleNumber - eegTime.segmentsTime(index,1))/(eeg.srate*3600*24) ;
                %%%%%%%%%%%%%%%%%%%%%%%%%
                
                segmentsCell{end+1} = {segment,prefix,infix,postfix,currentStartSampleNumber,currentEndSampleNumber,interpolatedElectrodes,currentSegmentStartinSerial};
                
                break;
            end
            disp('Corresponding marker was NOT found!!!');
        end 
    end 
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function segmentsCell = addInterpolationList(segmentsCell, interpolateSection, eegTime, timeFrom, timeEnd, srate, electrodesConversionMap);

createDB_constants
for segmentI=1:length(segmentsCell)
    for interpolateI=1:length(interpolateSection)
        
        % Continue to next row in case of NaN
        if (isnan(interpolateSection{interpolateI}))
            continue;
        end
        
        % Split & trim
        electrodesToInterpolate = strtrim(regexpi(interpolateSection{interpolateI},',','split'));
        tmpcfg = [];
        tmpcfg.electrodesConversionMap = electrodesConversionMap;
        electrodesToInterpolate = convert_electrodes_to_mcn(tmpcfg, electrodesToInterpolate);
        
        % Convert times to serial time
try
        dateVectorFromSerial = datenum(timeFrom{interpolateI},'dd.mm.yyyy hh:MM:ss'); % Matlab 64 bit sometimes has a bug when running this function twice
catch
    pause();
end
        dateVectorEndSerial = datenum(timeEnd{interpolateI},'dd.mm.yyyy hh:MM:ss');
        dateVectorStartRecordingSerial = datenum([num2str(eegTime.day) '.' num2str(eegTime.month) '.' num2str(eegTime.year) ' ' num2str(eegTime.hours) ':' num2str(eegTime.minutes) ':' num2str(eegTime.seconds)],'dd.mm.yyyy hh:MM:ss');
        
        % reduce ~2 seconds from dateVectorFromSerial and add ~2 seconds to
        % dateVectorEndSerial to make sure we don't miss any neccesary interpolation
        dateVectorFromSerial = dateVectorEndSerial - 3e-5;
        dateVectorEndSerial = dateVectorEndSerial + 3e-5;
        
        % Calculate the serial time of the segments' start point
        segmentStartSample = segmentsCell{segmentI}{sampleStartColumn};
        index = find( eegTime.segmentsTime(:,1) <= segmentStartSample );
            index = index(end); % This marks the last recording pause before the current sample
        timeAfterPause = eegTime.segmentsTime(index,2); % this is the time of the restart of the recording
        currentSegmentStartinSerial = timeAfterPause + (segmentStartSample - eegTime.segmentsTime(index,1))/(srate*3600*24) ;

        
        % Check if the start of the segment is in the current
        % interpolation interval
        if ((currentSegmentStartinSerial>=dateVectorFromSerial)&&(currentSegmentStartinSerial<dateVectorEndSerial))
            % Yes, it is! Do not interpolate, but write which electrodes
            % need to be interpolated in this segment.
            segmentsCell{segmentI}{interpolatedElectrodesColumn} = electrodesToInterpolate;
        end
    end
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function segmentsCell = addDrugsList(segmentsCell, eegTime, drugs)
%fill drug name to the  segmentsCell{segmentI}

drugs_flag = 0; % check if there were drugs
drugsToFill = [];
for segmentI=1:length(segmentsCell)
%     for drugId = 1:length(drugs)
%         
%         if(isnan(drugs{drugId}))
%             continue;
%         end
%         
%         drugDateFromSerial = datenum(timeFrom{drugId},'dd.mm.yyyy hh:MM:ss');
%         drugDateEndSerial = datenum(timeEnd{drugId},'dd.mm.yyyy hh:MM:ss');
%         
%         % Calculate the serial time of the segments' start point
%         segmentStartSample = segmentsCell{segmentI}{sampleStartColumn};
%         index = find( eegTime.segmentsTime(:,1) <= segmentStartSample );
%             index = index(end);
%         timeAfterPause = eegTime.segmentsTime(index,2);
%         currentSegmentStartinSerial = timeAfterPause + (segmentStartSample - eegTime.segmentsTime(index,1))/(eeg.srate*3600*24) ;
% 
%         % Check if the start of the segment is in the current
%         % interpolation interval
%         
%         if ((currentSegmentStartinSerial>=drugDateFromSerial)&&(currentSegmentStartinSerial<drugDateEndSerial))
%             %maybe need to append some drugs
%             drugs_flag = 1;
%             drugsToFill  = [drugsToFill  drugs{drugId} '_'];
%         end
%         
%     end
%     
    if drugs_flag == 0
        drugsToFill = 'CLEAN';
    else
        drugsToFill = [ drugsToFill(1:end-1)]; % 'end-1' is used to discard of the '_' at the end
    end
    segmentsCell{segmentI}(4) = {drugsToFill};
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function segmentStartinSerial = getSegmentsStartingTime(segmentIn, eegTime, srate)
% getSegmentsStartingTime gets a segment cell (as in the array segmentsCell)
% and returns its serial starting time.
 
createDB_constants
 
segmentStartSample = segmentIn{sampleStartColumn};
index = find( eegTime.segmentsTime(:,1) <= segmentStartSample );
    index = index(end);
timeAfterPause = eegTime.segmentsTime(index,2);
segmentStartinSerial = timeAfterPause + (segmentStartSample - eegTime.segmentsTime(index,1))/(srate*3600*24) ;    
 

% if strcmp(datestr(segmentStartinSerial, 'dd.mm.yyyy hh:MM:ss'), '28.11.2012 13:31:50')
%     pause()
% end
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveSegments(segmentsCell, inputDir, subDirName, validEegChannels, srate, eegTime)
% Save all segments in a Field Trip compitable file
 
createDB_constants
flags = ones(1,length(segmentsCell)); % used to make sure no segment is saved twice
 
for segmentI = 1:length(segmentsCell)
    if( flags(segmentI) == 1)
        data=[];
        data.label = validEegChannels; % cell-array containing strings, Nchan X 1
        data.fsample = srate; % sampling frequency in Hz. In fieldtrip this is termed "fsample" (sampling frequency). autoTRC2mat calls this srate (sampling rate)
        data.trial = [];
        data.time = [];
        data.interpolatedElectrodes = [];
        data.startTime = [];
        
        for segmentIin = segmentI:length(segmentsCell)
            if( flags(segmentIin) == 1 && strcmp(segmentsCell{segmentIin}{2},segmentsCell{segmentI}{2}) && ...
                    strcmp(segmentsCell{segmentIin}{3},segmentsCell{segmentI}{3}) && strcmp(segmentsCell{segmentIin}{4},segmentsCell{segmentI}{4}))
            % That is, if this segment is the same type (e.g. R_C_CLEAN) as
            % the one from the outer loop, add it to "data"
                flags(segmentIin) = 0;
                
                data.trial{end+1} = segmentsCell{segmentIin}{signalColumn};  % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is    Nchan X Nsamples
                data.time{end+1} = [0:1/srate:(size(segmentsCell{segmentIin}{signalColumn},2)-1)/srate];   % cell-array containing a time axis for each trial (1 X Ntrial), each time axis is a 1 X Nsamples vector
                data.interpolatedElectrodes{end+1} = segmentsCell{segmentIin}{interpolatedElectrodesColumn};
                data.startTime{end+1} = segmentsCell{segmentIin}{segmentStartinSerialColumn};
            end
        end
        
        segmentsTypeName = [segmentsCell{segmentI}{2},'_', segmentsCell{segmentI}{3}, '_', segmentsCell{segmentI}{4}];
        eval([segmentsTypeName ' = data;']);
        try
            if ~exist([inputDir subDirName '.mat'], 'file')
                save([inputDir subDirName '.mat'],segmentsTypeName);
            else
                save([inputDir subDirName '.mat'],segmentsTypeName,'-append');
            end
            
        catch
            disp('error');
        end
    end
    
    
end
end
