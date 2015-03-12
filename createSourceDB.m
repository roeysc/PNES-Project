% sourceAnalysisStatInSubject performs source analysis statistics between
% conditions and plots the brain activity

%% Set Path
path = 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\'; % Directory path with mat EEG files
outputPath = 'C:\Users\roeysc\Desktop\PNES\sourceDB\8-13\';
mriPath = 'C:\Users\roeysc\Desktop\PNES\MRI\realigned\';
patientNames = {'pLT1997', 'pSN1993', 'pSS1984'};
foilim = [8 13];
bands = [1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48]; % These were used in Shahar's article
conditions = {'BP', 'P', 'R', 'BE'};
eyes = {'O', 'C'};

for patientI = 1:length(patientNames)
    patientName = patientNames{patientI};
    for conditionI = 1:length(conditions)
        for eyesI = 1:2
            outputName = [patientName, '_', conditions{conditionI}, '_', eyes{eyesI},'_ConditionFilter'];
            
            %% Query the Condition
            flag = 0;
            flag = query({patientName}, path, conditions{conditionI} , eyes{eyesI}, 'A',1,1,1,1, 'Condition1');
            if flag == 0
                continue
            end
            queryFile1 = [path 'queries\Condition1'];

            mriFile = load([mriPath, patientName '.mat']); 
            mriFile = mriFile.mriReal;
            segmentedMriFile = [mriPath 'segmented\' patientName '.mat'];

            %% Perform Source Analysis
            % Define cfg for sourceAnalysisWrap
            cfg = [];
            cfg.output = 'powandcsd';
            cfg.analysistype = 'smoothing'; % 'maxperlen' or 'smoothing'
            cfg.foilim = foilim;
            cfg.keeptrials = 'yes';
            % [ sourceCondition1, sourceCondition2 ] = sourceAnalysisWrap(cfg, segmentedMriFile, queryFile1, queryFile2); % uses a filter for each trial
            [ sourceCondition1 ] = sourceAnalysisWrapConditionFilterOne(cfg, segmentedMriFile, queryFile1); % uses a filter for each condition
            
            save([outputPath, outputName], 'sourceCondition1')
            
             %% CHECKME Normalize the Source Structure
            % We normalize here because we want to use an atlas for different ROIs
             sourceCondition1Norm = sourceInterpoateAndNormalise(sourceCondition1, mriFile);
            save([outputPath, outputName ,'_Norm'], 'sourceCondition1Norm')
        
        end % of eyes
    end % of conditions
end % ofpatients

