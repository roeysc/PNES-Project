function [N, XAXIS, NAMES] = getFolderTrialsStatistics(cfg)
% getFolderTrialsStatistics uses getTrialsStatistics to plot histogram of
% trials lengths for all patients in cfg.inputDir.
% 
% cfg.inputDir
% cfg.type (condition type, e.g. R)
% cfg.eyes (O, C, U)
% 
% e.g.
% cfg =[];
% cfg.inputDir = 'C:\Users\Roey\Documents\Lab\PNES Project\LongSegments';
% cfg.type = {'P'};
% cfg.eyes = {'O', 'C', 'U'};
% [N, XAXIS, NAMES] = getFolderTrialsStatistics(cfg)


inputDir = cfg.inputDir;
type = cfg.type ;
eyes = cfg.eyes;
minTime = 0;
maxTime = inf;
split = 0;
outputName = 'Temp';
noInterpolatedNeighbours = 'yes';
files = getfullfiles([inputDir, filesep, '*.mat']);

N = cell(length(files),1);
XAXIS = cell(length(files),1);
NAMES = cell(length(files),1);

maxX = 0;
minX = [];
for fileI = 1:length(files)
    [~, NAMES{fileI}] = fileparts(files{fileI});
    flag = query (NAMES(fileI), inputDir, type, eyes,  'A' , minTime, maxTime, split, noInterpolatedNeighbours, outputName);
    if flag == 0
        N{fileI} = 0;
        XAXIS{fileI} = 0;
        continue        
    end
    
    data = load2struct([inputDir, filesep, 'queries', filesep, outputName, '.mat']);
    
    trialsLengths = zeros(1,length(data.time));
        for j = 1:length(data.time)
            trialsLengths(j) = size(data.time{j},2);
        end
        
        trialsLengths = trialsLengths./(data.fsample);

        [nTemp, xTemp] = hist(trialsLengths);
        xTemp = floor(xTemp);
        XAXIS{fileI} = unique(xTemp); % in integer seconds
        
        for i = 1:length(XAXIS{fileI})
            indices  = (xTemp == XAXIS{fileI}(i));
            N{fileI}(i) = sum(nTemp.*indices);
        end
        
        
        maxX = max(  maxX, max(XAXIS{fileI})  );
        if isempty(minX)
            minX = min(XAXIS{fileI});
        end
        minX = min(  minX, min(XAXIS{fileI})  ); 
end

 %% Plot Results
 XAXIS4plot = minX:1:maxX;
N4plot = zeros(length(files),length(XAXIS4plot));

 for fileI = 1:length(files)
    for xVal = 1:length(XAXIS{fileI})
        index = find(XAXIS4plot == XAXIS{fileI}(xVal))
        N4plot(fileI,index) = N{fileI}(xVal);
    end
end

figure;
bar(XAXIS4plot, N4plot', 'grouped');
title(['Condition ' type ' ' eyes]);
legend(NAMES{:})
ylabel('# of trials');
xlabel('time (s)');
      

end

