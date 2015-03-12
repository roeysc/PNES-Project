function [] = reReference (names, inputDir)

% reReference performs average rereferencing of EEG data in FieldTrip format (mat file)
%
% INPUT
% names - CELL - patients names (e.g.: pLT1997)
% inputDir - input directory where mat files are saved (the Data Base folder)
%
% OUTPUT
% mat files of similar names in a sub folder with the same name, ending with "rereferenced"
%
% e.g.: reReference({'pLT1997'}, 'C:\PNES\DB')
% e.g.: reReference({'pEC1980','pGR1992','pLT1997','pSG1991','pSN1993','pSS1984'}, 'C:\Users\roeysc\Desktop\PNES\DB')

if(inputDir(end)~='\')
    inputDir(end+1) = '\';
end
outputDir = [inputDir 'rereferenced\'];

for patientI = 1:length(names)
    patientName = names{patientI};
    fullPath = [inputDir, patientName, '.mat'];
    
    % Load patient's FieldTrip file
    if ~exist(fullPath, 'file')
        error(['Could not find file for patient ' patientName]);
    else
        patientData = load(fullPath);
    end
    
    % Go Over all conditions, in each one over all trials, in each one over 
    % all samples, and subtract the AVERAGE over all electrodes
    allConditionNames = fieldnames(patientData);
    for conditionI = 1:length(allConditionNames)
        
        conditionName = allConditionNames{conditionI};
        eval( ['trialsNum = length(patientData.' conditionName '.trial);'] );
        
        for trialI = 1:trialsNum
            % create a string called trialString that holds the trial name
            eval([ 'trialString = [ '' patientData.' conditionName '.trial{' num2str(trialI) '} '' ];'  ])
            % and subtract the AVERAGE over all electrodes
            eval([ trialString '=' trialString ' - repmat(mean(' trialString '), size(' trialString ',1),1);' ] );
        end % of trials loop
    end % of conditions loop

    % Save rereferenced file in appropriate sub folder
 
    
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