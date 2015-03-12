% function createDB_IScheck
% Description: This function creates a database of PSESNS patients.
% Input: inputDir - path to the main directory (where Excel files are)
% Output: None. But in each patient directory, creates a matlab file which
% contains all the processed segments.
%
% This version of createDB was created to deal with more EEG labels and
% a different format of segments labels that was used in the EEG recording
% of Roey by Racheli, to chekc inverse solution algorithms.

function createDB_IScheck(inputDir)

% Init
warning('Please update column matching in xls using regular expression');
warning('Assuming non-pause recordings!!!!');
pathdef;
ft_defaults;
timeFromColumn = 2;
timeEndColumn = 1;
interpolationColumn = 3;
drugsColumn = 4;
titlesRow = 1;
ALL_FREQ = 256;
highpass = 0.1;
lowpass = 48;
notch = 50;
gain = 1;
markerSampleColumn = 1;
markerNameColumn = 3;
sampleStartColumn = 5;
signalColumn = 1;
interpolatedElectrodesColumn = 7;

warning('All signal will be downsampled to 256Hz');

% validEEGLabels = {'Fp1','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','O2'};
validEEGLabels = {'Fp1','Fpz','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','Oz','O2','c5a','c6a','cza','f4a','a1','f3a','a2','c3a','f5','c1a','f1','c2a','f2','c4a','f6','c5','t4l','c1','p5','c2','p1','c6','p2','t3l','p6','tcp1','ob1','c3p','p3p','c1p','p1p','pza','pzp','c2p','p2p','c4p','p4p','tcp2','ob2'};

% backslah fix
if (inputDir(end)~='\')
   
    inputDir(end+1) = '\';

end

% Add the eeglab path from Rachel's computer
pathdef;

subDirs = dir(inputDir);

% For each patient
   for i=1:length(subDirs)
    
    % Skip non-directories
    if ((~(subDirs(i).isdir))||(strcmp(subDirs(i).name,'.'))||(strcmp(subDirs(i).name,'..')))
       
        continue;
        
    end
    
    % Delete patient's file if exists
    if exist([subDirs(i).name '.mat'], 'file')
        warning(['File ' subDirs(i).name '.mat exists. FILE WILL BE DELETED. Press ctrl+c to cancel']);
        pause();
        delete([subDirs(i).name '.mat']);
    end
    
    % Load patient's excel file
    [~,~,xlsPatient] = xlsread([inputDir subDirs(i).name '.xlsx']);
    interpolateSection  = []; timeFrom = []; timeEnd = []; drugs = []; % ###
    
    if ~isnan(xlsPatient{1})
        interpolateSection = xlsPatient(titlesRow+1:end,interpolationColumn);
        timeFrom = xlsPatient(titlesRow+1:end,timeFromColumn);
        timeEnd  = xlsPatient(titlesRow+1:end,timeEndColumn);
        drugs = xlsPatient(titlesRow+1:end,drugsColumn);
    end
    filesInSubDir = dir([inputDir subDirs(i).name '\*.TRC']);
    segmentsCell = {};
    
    % Find all the files (recordings) in each directory
    for j=1:length(filesInSubDir)
 
        filesInSubDir(j).name % Print the TRC file name on screen
        
        % Load relevant eeg files
        
        eeg = load([inputDir subDirs(i).name '\' filesInSubDir(j).name '.mat']);
        eegTime = load([inputDir subDirs(i).name '\' filesInSubDir(j).name '.TIME.mat']);         % Load time mat file
%%% 
% Fix eeg.mrk
fid = fopen('C:\Users\Rachelsh\Desktop\RoeyEEG\pRoey\EEG_1.TRC.mrk','r');
eeg.mrk = textscan(fid, '%s %s %s')
fclose(fid)

for i = 1:length(eeg.mrk{:,1}) % remove " signs from markers
    try
    eeg.mrk{1,3}{i}(1) = [];
    eeg.mrk{1,3}{i}(end) = [];
    
    eeg.mrk{1,1}{i} = str2num(eeg.mrk{1,1}{i});
    eeg.mrk{1,2}{i} = str2num(eeg.mrk{1,2}{i});
    
    catch
        pause()
    end
end

%%%
        
        
        
% matlab 2009b has problems with creating the channels as strings array
% with different sizes. Hence the following condition, using different formats of eeg.chan
% as recieved from autotrc2mat:
if strcmp(version('-release'),'2009b')
        for temp = 1: length(eeg.chan)
            validChansLocVec(temp) = ismember(eeg.chan{temp},validEEGLabels);
        end
else
        validChansLocVec = ismember(eeg.chan,validEEGLabels);
end

eeg.sig = eeg.sig(validChansLocVec,:);
        eeg.chan = eeg.chan(validChansLocVec);     
        
        % Split the signal by the given markers and Filter
        
        for markerI = 1:length(eeg.mrk{markerNameColumn})
        
            eeg.mrk{markerNameColumn}{markerI}
            
            prefix = [];
            infix = [];
            if(~all(isempty(regexpi(eeg.mrk{markerNameColumn}{markerI},'^(RS|MHRS|MHLS|MLRS|MLLS|SHRS|SHLS|SARS|SALS|SLRS|SLLS|SMS|MUSICS|VISUALS)_(U|O|C)_[\d]*[*]*$'))))
                disp('Marker found!');
                eeg.mrk{markerNameColumn}{markerI}
                
                numberSTR = (regexpi(eeg.mrk{markerNameColumn}{markerI},'[\d]*','match')); % take the number written in the marker. e.g: '1' in 'BPS_O_1'
                starSTR = cell2mat(regexpi(eeg.mrk{markerNameColumn}{markerI},'[*]*','match'));
                currentStartSampleNumber = eeg.mrk{markerSampleColumn}(markerI);
                    currentStartSampleNumber = currentStartSampleNumber{1};
                markerTypeS = regexpi(eeg.mrk{markerNameColumn}{markerI},'(RS|MHRS|MHLS|MLRS|MLLS|SHRS|SHLS|SARS|SALS|SLRS|SLLS|SMS|MUSICS|VISUALS)','match'); 
                markerTypeE = [markerTypeS{1}(1:end-1) 'E'];
                
                for coMarkerI = markerI+1:length(eeg.mrk{markerNameColumn})
                    if(~all(isempty(regexpi(eeg.mrk{markerNameColumn}{coMarkerI},cell2mat(['^' markerTypeE '_[U|O|C]_' numberSTR starSTR '$'])))))
                        disp('Corresponding marker was found');
                        eeg.mrk{markerNameColumn}{coMarkerI}
                        
                        currentEndSampleNumber = eeg.mrk{markerSampleColumn}(coMarkerI);
                            currentEndSampleNumber = currentEndSampleNumber{1};
                        segment = eeg.sig(:,currentStartSampleNumber:currentEndSampleNumber);
                        
                        % filter and down sampling each segment 
                        downfactor = eeg.srate/ALL_FREQ;
                        segment = simplefilter(segment',eeg.srate,downfactor,highpass,lowpass,notch,gain)';      
                        % (eeg.srate is not changed here because it is later used to calculate the segment's time)
                       
                        prefix = markerTypeS{1}(1:end-1);
                        infix = regexpi(eeg.mrk{markerNameColumn}{coMarkerI},['_[\w]_'],'match');
                        infix = infix{1}(2); % Get only U/O/C
  
                        
                        postfix = 'CLEAN';
                        interpolatedElectrodes = {'NONE'};
                        segmentsCell{end+1} = {segment,prefix,infix,postfix,currentStartSampleNumber,currentEndSampleNumber,interpolatedElectrodes};
                        
                        break;
                    end
                    disp('Corresponding marker was NOT found!!!');
                end
                               
            end
               
           
        end
       
        % Now go over the segment cell , Interpolate, Postificate
        % and Save
        
        % Go over all the segments and interpolate data by xls, and
        % add drugs by xls
        
        for segmentI=1:length(segmentsCell)
            
            for interpolateI=1:length(interpolateSection)
                
                % Continue to next row in case of NaN
                if (isnan(interpolateSection{interpolateI}))
                    continue;
                end
                
                % Split & trim
                electrodesToInterpolate = strtrim(regexpi(interpolateSection{interpolateI},',','split'));
                
                % Convert times to samples
                dateVectorFromSerial = datenum(timeFrom{interpolateI},'dd.mm.yyyy hh:MM:ss'); % Matlab 64 bit sometimes has a bug when running this function twice
                dateVectorEndSerial = datenum(timeEnd{interpolateI},'dd.mm.yyyy hh:MM:ss');
                dateVectorStartRecordingSerial = datenum([num2str(eegTime.day) '.' num2str(eegTime.month) '.' num2str(eegTime.year) ' ' num2str(eegTime.hours) ':' num2str(eegTime.minutes) ':' num2str(eegTime.seconds)],'dd.mm.yyyy hh:MM:ss');
                
                % Calculate the serial time of the segment
                segmentStartSample = segmentsCell{segmentI}{sampleStartColumn};
                index = find( eegTime.segmentsTime(:,1) <= segmentStartSample );
                index = index(end);
                
                timeAfterPause = eegTime.segmentsTime(index,2);
                
                currentSegmentStartinSerial = timeAfterPause + (segmentStartSample - eegTime.segmentsTime(index,1))/(eeg.srate*3600*24) ;
                
                % Check if the start of the segment is in the current
                % interpolation interval
                if ((currentSegmentStartinSerial>=dateVectorFromSerial)&&(currentSegmentStartinSerial<dateVectorEndSerial))
                    % Yes, it is!
                  segmentsCell{segmentI}{signalColumn} = fixelecByDist(segmentsCell{segmentI}{signalColumn}',eeg.chan',electrodesToInterpolate);  
                  segmentsCell{segmentI}{interpolatedElectrodesColumn} = electrodesToInterpolate;
                end
            end
            
            %fill drug name to the  segmentsCell{segmentI}
             drugs_flag = 0; % check if there were drugs
             drugsToFill = [];
             for drugId = 1:length(drugs)
                
                if(isnan(drugs{drugId}))
                    continue;
                end
             
                drugDateFromSerial = datenum(timeFrom{drugId},'dd.mm.yyyy hh:MM:ss');
                drugDateEndSerial = datenum(timeEnd{drugId},'dd.mm.yyyy hh:MM:ss');
                
                % Check if the start of the segment is in the current
                % interpolation interval
               
                if ((currentSegmentStartinSerial>=drugDateFromSerial)&&(currentSegmentStartinSerial<drugDateEndSerial))
                    %maybe need to append some drugs
                    drugs_flag = 1;
                    drugsToFill  = [drugsToFill  drugs{drugId} '_'];
                end    
                 
             end
             
             if drugs_flag == 0
                drugsToFill = 'CLEAN';
             else
                drugsToFill = [ drugsToFill(1:end-1)]; % 'end-1' is used to discard of the '_' at the end
             end
               segmentsCell{segmentI}(4) = {drugsToFill};        
            
        end
        
        
        
        
        
%         for k=2:length(interpolateSection)
%             
%             % Continue to next row in case of NaN
%             if (isnan(interpolateSection{k}))
%                 continue;
%             end
%             
%            % Split & trisegmentsCellsegmentsCellm 
%            electrodesToInterpolate = strtrim(regexpi(interpolateSection{k},',','split'))
% 
%            % Convert times to samples
%            dateVectorFromSerial = datenum(timeFrom{k},'dd.mm.yyyy hh:MM:ss');
%            dateVectorEndSerial = datenum(timeEnd{k},'dd.mm.yyyy hh:MM:ss');
%            dateVectorStartRecordingSerial = datenum([num2str(eegTime.day) '.' num2str(eegTime.month) '.' num2str(eegTime.year) num2str(eegTime.hours) ':' num2str(eegTime.minutes) ':' num2str(eegTime.seconds)]);
%                       
%            % Check if interpolated interval exists in current file
%         ????   if ((dateVectorFromSerial<dateVectorStartRecordingSerial)||((dateVectorEndSerial<dateVectorStartRecordingSerial)))
%                continue;
%            end
% 
%         ????   if ((dateVectorFromSerial+length(eeg.sig)/eeg.srate>(dateVectorStartRecordingSerial))||(dateVectorEndSerial+length(eeg.sig)/eeg.srate>(dateVectorStartRecordingSerial)))
%                 continue;
%            end
%            
%      %      dateVectorFromSample =  
%            interpolateFromInSamples = (dateVectorFromSerial-dateVectorStartRecordingSerial)*eeg.srate;
%            
%            
%            % Fix elec
        
        
        
%         % Filter
%         downfactor = eeg.srate/ALL_FREQ;
%         eeg.sig = simplefilter(eeg.sig',eeg.srate,downfactor,highpass,lowpass,notch,gain)';

       
        
 %       autotrc2mat([inputDir subDirs(i).name '\' filesInSubDir(j).name]);
               
    end
    
    % Save all segments in a Field Trip file
    
    flags = ones(1,length(segmentsCell)); % used to make sure no segment is saved twice
    
    warning('Make sure all labels have the same channels labels and sampling rate');
        
    for segmentI = 1:length(segmentsCell)
        if( flags(segmentI) == 1)
            data=[];
            data.label = validEEGLabels; % cell-array containing strings, Nchan X 1
            data.fsample = ALL_FREQ; % sampling frequency in Hz, single number
            data.trial = [];
            data.time = [];
            data.interpolatedElectrodes = [];
            
            for segmentIin = segmentI:length(segmentsCell)
                if( flags(segmentIin) == 1 && strcmp(segmentsCell{segmentIin}{2},segmentsCell{segmentI}{2}) && ...
                    strcmp(segmentsCell{segmentIin}{3},segmentsCell{segmentI}{3}) && strcmp(segmentsCell{segmentIin}{4},segmentsCell{segmentI}{4}))
                    
                    flags(segmentIin) = 0;
                    
                    data.trial{end+1} = segmentsCell{segmentIin}{signalColumn};  % cell-array containing a data matrix for each trial (1 X Ntrial), each data matrix is    Nchan X Nsamples 
                    data.time{end+1} = [0:1/ALL_FREQ:(size(segmentsCell{segmentIin}{signalColumn},2)-1)/ALL_FREQ];   % cell-array containing a time axis for each trial (1 X Ntrial), each time axis is a 1 X Nsamples vector 
                    data.interpolatedElectrodes{end+1} = segmentsCell{segmentIin}{interpolatedElectrodesColumn};
                end
            end
            
            segmentsTypeName = [segmentsCell{segmentI}{2},'_', segmentsCell{segmentI}{3}, '_', segmentsCell{segmentI}{4}];
            eval([segmentsTypeName ' = data;']);
            try
                if ~exist([inputDir subDirs(i).name '.mat'], 'file')
                    save([inputDir subDirs(i).name '.mat'],segmentsTypeName);
                else
                    save([inputDir subDirs(i).name '.mat'],segmentsTypeName,'-append');
                end

            catch
                disp('error');
            end
        end

        
    end

end

end