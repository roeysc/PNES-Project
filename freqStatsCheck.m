%% freqStatsCheck.m
close all;
clear; clc;
%% freqStatsCheck is used to perform a statistical frequency analysis on two condition.
% First enter the two condition names - Condition1 and Condition2 - and the Data Base path.
% Change the frequency bands to meet your needs (* * * IMPORTANT * * *: make sure the same bands are used in freqAnalysisStat.m)
% Next change the condition parameters in the Query section (inside the eval function).

% ft_defaults
Condition1 = 'RestOpen'; % Blue in graph
Condition2 = 'RestClosed'; % Red in graph

% path = 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\normStandard'; % the DB path (where mat files are saved)
path = 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced'; % the DB path (where mat files are saved)

% bands =  [1 4; 4 8; 8 9; 9 12 ; 12 16;16 20; 20 30; 30 48]; % These were used by us
bands = [1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48]; % These were used in Shahar's article

%% Query
% ''pSN1993'' ''pSS1984''  ''pSG1991'' (no RO or RC)  ''pGR1992'' ''pCE1985'' (no RO) ''pLT1997''
eval([    '  query({''pSS1984'' },'  '''' path '''' ', ''R'', ''O'', ''A'', 1, 1, 1, 1,' '''' Condition1 '''' ')'    ] );
eval([    '  query({''pSS1984'' },'  '''' path '''' ', ''R'', ''C'', ''A'', 1, 1, 1,1,' '''' Condition2 '''' ')'    ] );

%% Frequency Analysis
% Define cfg for freqAnalysisWrap
cfg = [];
cfg.output = 'pow';
cfg.analysistype = 'smoothing'; % 'maxperlen' (using mean) or 'smoothing'
cfg.foilim = []; % to be configured in forthcoming loop
cfg.keeptrials = 'yes';

% Perform frequency analysis on first band, and then add the power spectrum
% (or other output) from all other bands

if strcmp(cfg.analysistype, 'maxperlen')
    
    cfg.foilim = [ bands(1), bands(end) ];
    eval([  'freq1 =   freqAnalysisWrap(cfg, ' '''' path '\queries\', Condition1, '''' ')'  ]); 
    eval([  'freq2 =   freqAnalysisWrap(cfg, ' '''' path '\queries\', Condition2, '''' ')'  ]); 
    
elseif strcmp(cfg.analysistype, 'smoothing')
    
    cfg.foilim = bands(1,:);
    eval([  'freq1 =   freqAnalysisWrap(cfg, ' '''' path '\queries\', Condition1, '''' ')'  ]); 
    eval([  'freq2 =   freqAnalysisWrap(cfg, ' '''' path '\queries\', Condition2, '''' ')'  ]); 

    for bandI = 2:size(bands,1);
        cfg.foilim = bands(bandI,:);
        eval([  'freq1tmp =   freqAnalysisWrap(cfg, ' '''' path '\queries\', Condition1, '''' ')'  ]); 
        eval([  'freq2tmp =   freqAnalysisWrap(cfg, ' '''' path '\queries\', Condition2, '''' ')'  ]); 

        freq1.powspctrm(:,:,bandI) = freq1tmp.powspctrm;
        freq2.powspctrm(:,:,bandI) = freq2tmp.powspctrm;    
        
        freq1.freq= [freq1.freq freq1tmp.freq]; % in the smoothing option "freq" holds the center of each frequency band
        freq2.freq = [freq2.freq freq2tmp.freq];
        
    end
    
else
    error('the cfg.analysistype you specified is not supported');
end
    
%% Take the Mean over all segments and use it to Plot the Power Spectrum
trialsNum1 = size(freq1.powspctrm,1);
trialsNum2= size(freq2.powspctrm,1);

labels = freq1.label;
frequencies = freq1.freq;
temp = [];
for elecI = 1:length(labels)
    temp = mean( freq1.powspctrm(:,elecI,:), 1); % take the mean overall segments, but save different frequencies
    temp = temp(:)'; % convert to vector
    powSpec1(elecI,:) = temp;
    temp = [];
    temp = mean( freq2.powspctrm(:,elecI,:), 1); % take the mean overall segments, but save different frequencies
    temp = temp(:)'; % convert to vector
    powSpec2(elecI,:) = temp;
    temp = [];
end


%% Plot Mean (over all segments) Power Spectrum of both conditions
figure;
Y1 = [1:3:3*length(labels)];
bar3(Y1, powSpec1,0.3,'b');
hold on
Y2 = [2:3:3*length(labels)];
bar3(Y2, powSpec2,0.3,'r');
set(gca,'Ytick', 1:3:3*length(labels),'YTickLabel',labels,'Xtick',1:length(frequencies), 'XTickLabel',frequencies,'FontSize',6);
view(-15,30);

%% Take the mean over Bands in case of 'maxperlen'
if strcmp(cfg.analysistype, 'maxperlen')
    freqBands1 = freq1; % Make sure the output freqBands is in the correct format
    freqBands2 = freq2; % Make sure the output freqBands is in the correct format
    
    freqBands1.freq = 1:size(bands,1);
    freqBands2.freq = 1:size(bands,1);
    
    for freqBandI = 1:size(bands,1)
        indexBegin = find(freq1.freq >= bands(freqBandI,1));
        indexBegin = indexBegin (1);
        indexEnd = find(freq1.freq <= bands(freqBandI,2));
        indexEnd = indexEnd(end);
    
        freqBands1.powspctrm(:,:,freqBandI) = mean(  freq1.powspctrm(:,:,indexBegin:indexEnd), 3);
        freqBands2.powspctrm(:,:,freqBandI) = mean(  freq2.powspctrm(:,:,indexBegin:indexEnd), 3);
    end
    freqBands1.powspctrm(:,:,freqBandI+1:end) = []; % delete all unnecessary cells
    freqBands2.powspctrm(:,:,freqBandI+1:end) = []; % delete all unnecessary cells
    
    freq1 = freqBands1;
    freq2 = freqBands2;
end

%% Normalize Frequency Power (per trial over power of bands)
% % % cfg.type = 'maxpertrialoverbands'; % 'meanpertrial' or 'maxpertrial' or 'maxpertrialoverbands'
% % % freq1 = freqNorm(cfg, freq1);
% % % freq2 = freqNorm(cfg, freq2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELETE THIS PART (ONLY USED TO CHECK HOW PLOT LOOKS AFTER NORMALIZATION) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %             %% Take the Mean over all segments and use it to Plot the Power Spectrum
% % %             trialsNum1 = size(freq1.powspctrm,1);
% % %             trialsNum2= size(freq2.powspctrm,1);
% % % 
% % %             labels = freq1.label;
% % %             frequencies = freq1.freq;
% % %             temp = [];
% % %             for elecI = 1:length(labels)
% % %                 temp = mean( freq1.powspctrm(:,elecI,:), 1); % take the mean overall segments, but save different frequencies
% % %                 temp = temp(:)'; % convert to vector
% % %                 powSpec1(elecI,:) = temp;
% % %                 temp = [];
% % %                 temp = mean( freq2.powspctrm(:,elecI,:), 1); % take the mean overall segments, but save different frequencies
% % %                 temp = temp(:)'; % convert to vector
% % %                 powSpec2(elecI,:) = temp;
% % %                 temp = [];
% % %             end
% % %             %% Plot Mean (over all segments) Power Spectrum of both conditions
% % %             figure;
% % %             Y1 = [1:3:3*length(labels)];
% % %             bar3(Y1, powSpec1,0.3,'b');
% % %             hold on
% % %             Y2 = [2:3:3*length(labels)];
% % %             bar3(Y2, powSpec2,0.3,'r');
% % %             set(gca,'Ytick', 1:3:3*length(labels),'YTickLabel',labels,'Xtick',1:length(frequencies), 'XTickLabel',frequencies,'FontSize',6);
% % %             view(-15,30);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run Statistics
stats = freqAnalysisStatCluster( cfg, freq1, freq2 );
frequencyBands = stats.freq;

%% Plot Statistics Mask
figure
subplotSize = ceil(sqrt(size(stats.mask,2)));
for bandI = 1:size(stats.mask,2)
        
    subplot(subplotSize,subplotSize,bandI);
    
    mask = zeros(5);
    maskLabels = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
    maskVec = stats.mask(:,bandI);

    % create matrix for saving which condition was bigger
    % CHECKME: make sure this is used only if mean was taken in the statistics
    biggerCondition = 0.5*ones(5);
    biggerConditionAll= powSpec1<powSpec2; % a matrix saving which condition had bigger mean over trials in each electrode and each band
    biggerConditionAll= biggerConditionAll + 1;
    
    for elecI = 1:length(labels)
        index = find( strcmp(maskLabels ,labels(elecI)) );
        mask(index) = maskVec(elecI);
        biggerCondition(index) = biggerConditionAll(elecI, bandI);
    end
    
    % put 0.5 where there are no electrodes in the plot
    index = find( strcmp(maskLabels ,'.') );
    mask(index) = 0.5; % this was eventually not used here, but never mind
    
    % create a colored mask that holds the bigger condition only in
    % significant electrodes
    coloredMask = biggerCondition;
    coloredMask(coloredMask==1) = 0; % 0 = blue
    coloredMask(coloredMask==2) = 12; % 12 = red    
    coloredMask(coloredMask==0.5) = 8; % 8 = gray
    coloredMask(mask==0) = 8; % 8 = gray
    colormap(lines)
    imagesc(coloredMask, [0 15])
       
    [x,y] = meshgrid(1:5,1:5);   % Create x and y coordinates for the strings
    textStrings = maskLabels;
    hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
    
    % define colors according to bigger condition
    % red = [1 0 0 ], blue = [0 0 1], white = [1 1 1]
    textColors = repmat(mask(:) < 1  ,1,3);
    index = find( strcmp(maskLabels ,'.') );

    
    
    set(hStrings,{'Color'},num2cell(textColors,2)); 

    eval(   [ 'title( ''' num2str(bands(bandI,1)) ' - ' num2str(bands(bandI,2)) '' ' Hz' '''' ');' ]  );
end

%% Plot Statistics Probability
figure
for bandI = 1:size(stats.prob,2)
    subplot(subplotSize,subplotSize,bandI);
    
    prob = zeros(5);
    probLabels = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
    probText = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
    probVec = stats.prob(:,bandI);

    for elecI = 1:length(labels)
        index = find( strcmp(probLabels ,labels(elecI)) );
        prob(index) = probVec(elecI);        
        probText{index} = sprintf('%.3g', probVec(elecI));
    end
    prob(1) = 0;
    prob(end) = 1;
    imagesc(-prob)
    colormap(gray) 
    [x,y] = meshgrid(1:5,1:5);   % Create x and y coordinates for the strings
    textStrings = maskLabels;
    
    hStrings = text(x(:),y(:),probText, 'HorizontalAlignment','center');
    textColors = repmat(prob(:) > 0.5  ,1,3); 
    set(hStrings,{'Color'},num2cell(textColors,2)); 

    eval(   [ 'title( ''' num2str(bands(bandI,1)) ' - ' num2str(bands(bandI,2)) '' ' Hz' '''' ');' ]  );
end

% Display the number of trials in each condition
trialsNum1 = size(freq1.powspctrm,1);
trialsNum2= size(freq2.powspctrm,1);
str = sprintf( [ Condition1 ' trials: %g' ], size(freq1.powspctrm,1) );
disp(str);
str = sprintf( [ Condition2 ' trials: %g' ], size(freq2.powspctrm,1) );
disp(str);


% %% Make Random Permutations of each condition to make sure no significant
% %% differences within conditions
% load('C:\Users\roeysc\Desktop\PNES\DB\queries\RestAll.mat')
% data1 = data;
% data2 = data;
% 
% x = randperm(size(data.trial,2));
% x1 = x(1:floor(length(x)/2));
% x2 = x(floor(length(x)/2)+1:end);
% 
% data1.trial = data.trial(1,x1);
% data1.time = data.time(1,x1);
% 
% data2.trial = data.trial(1,x2);
% data2.time= data.time(1,x2);
% 
% data = data1;
% save( 'C:\Users\roeysc\Desktop\PNES\DB\queries\RestClosedOne.mat' , 'data');
% data = data2;
% save( 'C:\Users\roeysc\Desktop\PNES\DB\queries\RestClosedTwo.mat' ,
% 'data');