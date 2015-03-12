function [N, XAXIS] = getTrialsStatistics(matFilePath)
% getTrialsStatistics plots a histogram of trials lengths of each trial
% type.

    load(matFilePath);
    conditionNames = who; % save the names of all trails conditions in the matFilePath.
    conditionNames(   strcmp(conditionNames, 'matFilePath')   ) = []; %delete the 'matFilePath' from the list.
    
    N = cell(length(conditionNames),1);
    XAXIS = cell(length(conditionNames),1);
    
    for i = 1:length(conditionNames)
        name = conditionNames{i};
        name((name == '_')) = ' ' ;
        eval([ 'temp =' conditionNames{i} ]);
        
        trialsLengths = zeros(1,length(temp.time));
        for j = 1:length(temp.time)
            trialsLengths = [trialsLengths, size(temp.time{j},2) ];
        end
        
        eval([ 'sampleFrequency = ', conditionNames{i} '.fsample;']);
        trialsLengths = trialsLengths./sampleFrequency;

        [ N{i}, XAXIS{i} ] = hist(trialsLengths);
        
        figure;
        hist(trialsLengths);
        title([name, ' - ', num2str(length(temp.time)), ' trials']);
        xlabel('trial length (s)')
    end
    
%     bar(b,y, 'grouped');
%     title('Grouped bar chart');
    
    
end