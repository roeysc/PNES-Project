function [] = normStandard (names, inputDir)

% reReference performs average rereferencing of EEG data in FieldTrip format (mat file)
%
% INPUT
% names - CELL - patients names (e.g.: pLT1997)
% inputDir - input directory where mat files are saved (the Data Base folder, preferably AFTER REREFERENCING)
%
% OUTPUT
% mat files of similar names in a sub folder with the same name, ending with "normStandart"
%
% e.g.: normStandard({'pLT1997'}, 'C:\PNES\DB\rereferenced')
% e.g.: normStandard({'pEC1980','pGR1992','pLT1997','pSG1991','pSN1993','pSS1984'}, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced')
%
% NOTICE: the mat files seem to change in size after standartization-normalization is done, yet this seemsto be normal

if(inputDir(end)~='\')
    inputDir(end+1) = '\';
end
outputDir = [inputDir 'normStandard\'];

for patientI = 1:length(names)
    patientName = names{patientI};
    fullPath = [inputDir, patientName, '.mat'];
    
    % Load patient's FieldTrip file
    if ~exist(fullPath, 'file')
        error(['Could not find file for patient ' patientName]);
    else
        patientData = load(fullPath);
    end

    trialsMat = zeros(19,1); % one long  matrix to hold all trials (and in the darkness bind them)
    
    % Go Over all conditions, and add all trials to one long matrix
    allConditionNames = fieldnames(patientData);
    for conditionI = 1:length(allConditionNames)
        
        conditionName = allConditionNames{conditionI};
        eval( ['trialsNum = length(patientData.' conditionName '.trial);'] );
        
        for trialI = 1:trialsNum
            % create a string called trialString that holds the trial name
            eval([ 'trialString = [ '' patientData.' conditionName '.trial{' num2str(trialI) '} '' ];'  ])
            % and append the trial to the trialMat trials matrix
            eval([ 'trialsMat = [trialsMat,' trialString '];'] );
        end % of trials loop
    end % of conditions loop

    % Delete first column which is zeros
    trialsMat = trialsMat(:, 2:end);
    
    % Calculate mean and STD over all electrodes
    Mean = mean(trialsMat,2);
    STD = sqrt(var(trialsMat')); % trialsMat' is used in ordertotake the variance over all COLUMNS
    STD = STD';
    
    % Go Over all conditions AGAIN, subtract the mean of each electrode and
    % divide by its STD
    allConditionNames = fieldnames(patientData);
    for conditionI = 1:length(allConditionNames)
        
        conditionName = allConditionNames{conditionI};
        eval( ['trialsNum = length(patientData.' conditionName '.trial);'] );
        
        for trialI = 1:trialsNum
            % create a string called trialString that holds the trial name
            eval([ 'trialString = [ '' patientData.' conditionName '.trial{' num2str(trialI) '} '' ];'  ])
            % find its size
            eval( [ 'trialSize = size(' trialString ');'  ] );
            % and subtract the AVERAGE over all electrodes
            eval([ trialString '=' trialString ' - repmat(Mean, 1, trialSize(2));' ] );
            % and divide by the STD
            eval([ trialString '=' trialString ' ./ repmat(STD, 1, trialSize(2));' ] );
            
        end % of trials loop
    end % of conditions loop

    
     % Save normalized-standartized file in appropriate sub folder
    if ~exist(outputDir, 'dir')
        mkdir(outputDir)
    end

    existFlag = 1;
    if ( exist([outputDir, patientName '.mat'], 'file') && existFlag )
        warning('File already exists! Press ctrl+c to cancel, or any other key to continue.')
        pause();
        delete([outputDir, patientName '.mat']);
        existFlag = 0;
    end
    
    % Save all conditions in the appropriate file
    for conditionI = 1:length(allConditionNames)
        conditionName = allConditionNames{conditionI};
        conditionTemp = allConditionNames{conditionI};
      
        eval( [ conditionTemp ' = patientData.' conditionName ';']);
        
        
        if ( ~exist([outputDir, patientName '.mat'], 'file') )
            save([outputDir, patientName, '.mat'], conditionName);
        else % append the file (add more conditions)
            save([outputDir, patientName, '.mat'], conditionName, '-append');
        end
    end

end % of patients loop