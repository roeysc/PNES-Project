close all;
clear; clc;

bands = [1 4; 4 8; 8 13; 13 18; 18 24; 24 30; 30 40; 40 48];
cfg.bands = bands;
cfg.sqroot = 'yes';

%% Query
Condition1 = 'Condition1'; % Blue in graph
Condition2 = 'Condition2'; % Red in graph
path = 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced'; % the DB path (where mat files are saved)
% ''pSN1993'' ''pSS1984''  ''pSG1991'' (no RO or RC)  ''pGR1992'' ''pCE1985'' (no RO) ''pLT1997''
eval([    '  query({ ''pSS1984'' },'  '''' path '''' ', ''R'', ''O'', ''A'', 2, 2, 1, 1,' '''' Condition1 '''' ')'    ] );
eval([    '  query({ ''pSS1984'' },'  '''' path '''' ', ''R'', ''C'', ''A'', 2, 2, 1, 1,' '''' Condition2 '''' ')'    ] );

%% Frequency Analysis
cfg.analysistype = 'smoothing';
[freqAbs1 freqRel1] = freqAbsRel(cfg, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\queries\Condition1.mat')
[freqAbs2 freqRel2] = freqAbsRel(cfg, 'C:\Users\roeysc\Desktop\PNES\DB\rereferenced\queries\Condition2.mat')

[freqCord1, freqCord2 ] = freqCordance([], freqAbs1, freqRel1, freqAbs2, freqRel2);

% % % %% PLOT ABSOLUTE POWER SPECTRUM and STATISTICS
% % %             freq1 = freqAbs1;
% % %             freq2 = freqAbs2;
% % % 
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
% % % 
% % %             %% Plot Mean (over all segments) Power Spectrum of both conditions
% % %             figure;
% % %             Y1 = [1:3:3*length(labels)];
% % %             bar3(Y1, powSpec1,0.3,'b');
% % %             hold on
% % %             Y2 = [2:3:3*length(labels)];
% % %             bar3(Y2, powSpec2,0.3,'r');
% % %             set(gca,'Ytick', 1:3:3*length(labels),'YTickLabel',labels,'Xtick',1:length(frequencies), 'XTickLabel',frequencies,'FontSize',6);
% % %             view(-15,30);
% % % 
% % %             %% Take the mean over Bands in case of 'maxperlen'
% % %             if strcmp(cfg.analysistype, 'maxperlen')
% % %                 freqBands1 = freq1; % Make sure the output freqBands is in the correct format
% % %                 freqBands2 = freq2; % Make sure the output freqBands is in the correct format
% % % 
% % %                 freqBands1.freq = 1:size(bands,1);
% % %                 freqBands2.freq = 1:size(bands,1);
% % % 
% % %                 for freqBandI = 1:size(bands,1)
% % %                     indexBegin = find(freq1.freq >= bands(freqBandI,1));
% % %                     indexBegin = indexBegin (1);
% % %                     indexEnd = find(freq1.freq <= bands(freqBandI,2));
% % %                     indexEnd = indexEnd(end);
% % % 
% % %                     freqBands1.powspctrm(:,:,freqBandI) = mean(  freq1.powspctrm(:,:,indexBegin:indexEnd), 3);
% % %                     freqBands2.powspctrm(:,:,freqBandI) = mean(  freq2.powspctrm(:,:,indexBegin:indexEnd), 3);
% % %                 end
% % %                 freqBands1.powspctrm(:,:,freqBandI+1:end) = []; % delete all unnecessary cells
% % %                 freqBands2.powspctrm(:,:,freqBandI+1:end) = []; % delete all unnecessary cells
% % % 
% % %                 freq1 = freqBands1;
% % %                 freq2 = freqBands2;
% % %             end
% % %             
% % %             %% Run Statistics
% % %             stats = freqAnalysisStatCluster( cfg, freq1, freq2 );
% % %             frequencyBands = stats.freq;
% % % 
% % %             %% Plot Statistics Mask
% % %             figure
% % %             subplotSize = ceil(sqrt(size(stats.mask,2)));
% % %             for bandI = 1:size(stats.mask,2)
% % % 
% % %                 subplot(subplotSize,subplotSize,bandI);
% % % 
% % %                 mask = zeros(5);
% % %                 maskLabels = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
% % %                 maskVec = stats.mask(:,bandI);
% % % 
% % %                 for elecI = 1:length(labels)
% % %                     index = find( strcmp(maskLabels ,labels(elecI)) );
% % %                     mask(index) = maskVec(elecI);        
% % %                 end
% % % 
% % %                 index = find( strcmp(maskLabels ,'.') );
% % %                 mask(index) = 0.5;
% % % 
% % %                 imagesc(mask)
% % %                 colormap(gray) 
% % %                 [x,y] = meshgrid(1:5,1:5);   % Create x and y coordinates for the strings
% % %                 textStrings = maskLabels;
% % %                 hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
% % %                 textColors = repmat(mask(:) < 1  ,1,3); 
% % %                 set(hStrings,{'Color'},num2cell(textColors,2)); 
% % % 
% % %                 eval(   [ 'title( ''' num2str(bands(bandI,1)) ' - ' num2str(bands(bandI,2)) '' ' Hz' '''' ');' ]  );
% % %             end
% % % 
% % %             %% Plot Statistics Probability
% % %             figure
% % %             for bandI = 1:size(stats.prob,2)
% % %                 subplot(subplotSize,subplotSize,bandI);
% % % 
% % %                 prob = zeros(5);
% % %                 probLabels = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
% % %                 probText = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
% % %                 probVec = stats.prob(:,bandI);
% % % 
% % %                 for elecI = 1:length(labels)
% % %                     index = find( strcmp(probLabels ,labels(elecI)) );
% % %                     prob(index) = probVec(elecI);        
% % %                     probText{index} = sprintf('%.3g', probVec(elecI));
% % %                 end
% % %                 prob(1) = 0;
% % %                 prob(end) = 1;
% % %                 imagesc(-prob)
% % %                 colormap(gray) 
% % %                 [x,y] = meshgrid(1:5,1:5);   % Create x and y coordinates for the strings
% % %                 textStrings = maskLabels;
% % % 
% % %                 hStrings = text(x(:),y(:),probText, 'HorizontalAlignment','center');
% % %                 textColors = repmat(prob(:) > 0.5  ,1,3); 
% % %                 set(hStrings,{'Color'},num2cell(textColors,2)); 
% % % 
% % %                 eval(   [ 'title( ''' num2str(bands(bandI,1)) ' - ' num2str(bands(bandI,2)) '' ' Hz' '''' ');' ]  );
% % %             end
% % % %% PLOT RELATIVE POWER SPECTRUM and STATISTICS
% % %             freq1 = freqRel1;
% % %             freq2 = freqRel2;
% % % 
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
% % % 
% % %             %% Plot Mean (over all segments) Power Spectrum of both conditions
% % %             figure;
% % %             Y1 = [1:3:3*length(labels)];
% % %             bar3(Y1, powSpec1,0.3,'b');
% % %             hold on
% % %             Y2 = [2:3:3*length(labels)];
% % %             bar3(Y2, powSpec2,0.3,'r');
% % %             set(gca,'Ytick', 1:3:3*length(labels),'YTickLabel',labels,'Xtick',1:length(frequencies), 'XTickLabel',frequencies,'FontSize',6);
% % %             view(-15,30);
% % % 
% % %             %% Take the mean over Bands in case of 'maxperlen'
% % %             if strcmp(cfg.analysistype, 'maxperlen')
% % %                 freqBands1 = freq1; % Make sure the output freqBands is in the correct format
% % %                 freqBands2 = freq2; % Make sure the output freqBands is in the correct format
% % % 
% % %                 freqBands1.freq = 1:size(bands,1);
% % %                 freqBands2.freq = 1:size(bands,1);
% % % 
% % %                 for freqBandI = 1:size(bands,1)
% % %                     indexBegin = find(freq1.freq >= bands(freqBandI,1));
% % %                     indexBegin = indexBegin (1);
% % %                     indexEnd = find(freq1.freq <= bands(freqBandI,2));
% % %                     indexEnd = indexEnd(end);
% % % 
% % %                     freqBands1.powspctrm(:,:,freqBandI) = mean(  freq1.powspctrm(:,:,indexBegin:indexEnd), 3);
% % %                     freqBands2.powspctrm(:,:,freqBandI) = mean(  freq2.powspctrm(:,:,indexBegin:indexEnd), 3);
% % %                 end
% % %                 freqBands1.powspctrm(:,:,freqBandI+1:end) = []; % delete all unnecessary cells
% % %                 freqBands2.powspctrm(:,:,freqBandI+1:end) = []; % delete all unnecessary cells
% % % 
% % %                 freq1 = freqBands1;
% % %                 freq2 = freqBands2;
% % %             end
% % % %% Run Statistics
% % % stats = freqAnalysisStatCluster( cfg, freq1, freq2 );
% % % frequencyBands = stats.freq;
% % % 
% % % %% Plot Statistics Mask
% % % figure
% % % subplotSize = ceil(sqrt(size(stats.mask,2)));
% % % for bandI = 1:size(stats.mask,2)
% % %         
% % %     subplot(subplotSize,subplotSize,bandI);
% % %     
% % %     mask = zeros(5);
% % %     maskLabels = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
% % %     maskVec = stats.mask(:,bandI);
% % % 
% % %     for elecI = 1:length(labels)
% % %         index = find( strcmp(maskLabels ,labels(elecI)) );
% % %         mask(index) = maskVec(elecI);        
% % %     end
% % % 
% % %     index = find( strcmp(maskLabels ,'.') );
% % %     mask(index) = 0.5;
% % %     
% % %     imagesc(mask)
% % %     colormap(gray) 
% % %     [x,y] = meshgrid(1:5,1:5);   % Create x and y coordinates for the strings
% % %     textStrings = maskLabels;
% % %     hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
% % %     textColors = repmat(mask(:) < 1  ,1,3); 
% % %     set(hStrings,{'Color'},num2cell(textColors,2)); 
% % % 
% % %     eval(   [ 'title( ''' num2str(bands(bandI,1)) ' - ' num2str(bands(bandI,2)) '' ' Hz' '''' ');' ]  );
% % % end
% % % 
% % % %% Plot Statistics Probability
% % % figure
% % % for bandI = 1:size(stats.prob,2)
% % %     subplot(subplotSize,subplotSize,bandI);
% % %     
% % %     prob = zeros(5);
% % %     probLabels = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
% % %     probText = {'.' 'Fp1' '.' 'Fp2' '.'; 'F7' 'F3' 'Fz' 'F4' 'F8'; 'T3' 'C3' 'Cz' 'C4' 'T4'; 'T5' 'P3' 'Pz' 'P4' 'T6' ; '.' 'O1' '.' 'O2' '.'} ;
% % %     probVec = stats.prob(:,bandI);
% % % 
% % %     for elecI = 1:length(labels)
% % %         index = find( strcmp(probLabels ,labels(elecI)) );
% % %         prob(index) = probVec(elecI);        
% % %         probText{index} = sprintf('%.3g', probVec(elecI));
% % %     end
% % %     prob(1) = 0;
% % %     prob(end) = 1;
% % %     imagesc(-prob)
% % %     colormap(gray) 
% % %     [x,y] = meshgrid(1:5,1:5);   % Create x and y coordinates for the strings
% % %     textStrings = maskLabels;
% % %     
% % %     hStrings = text(x(:),y(:),probText, 'HorizontalAlignment','center');
% % %     textColors = repmat(prob(:) > 0.5  ,1,3); 
% % %     set(hStrings,{'Color'},num2cell(textColors,2)); 
% % % 
% % %     eval(   [ 'title( ''' num2str(bands(bandI,1)) ' - ' num2str(bands(bandI,2)) '' ' Hz' '''' ');' ]  );
% % % end

%% PLOT CORDANCE POWER SPECTRUM and STATISTICS
            freq1 = freqCord1;
            freq2 = freqCord2;

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

                for elecI = 1:length(labels)
                    index = find( strcmp(maskLabels ,labels(elecI)) );
                    mask(index) = maskVec(elecI);        
                end

                index = find( strcmp(maskLabels ,'.') );
                mask(index) = 0.5;

                imagesc(mask)
                colormap(gray) 
                [x,y] = meshgrid(1:5,1:5);   % Create x and y coordinates for the strings
                textStrings = maskLabels;
                hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
                textColors = repmat(mask(:) < 1  ,1,3); 
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

%%  Display the number of trials in each condition
trialsNum1 = size(freq1.powspctrm,1);
trialsNum2= size(freq2.powspctrm,1);
str = sprintf( [ Condition1 ' trials: %g' ], size(freq1.powspctrm,1) );
disp(str);
str = sprintf( [ Condition2 ' trials: %g' ], size(freq2.powspctrm,1) );
disp(str);
