clear; clc;

signal = load('C:\Users\roeysc\Desktop\PNES\queries\sinus.mat');

t = signal.data.time{1};

% %% Single Trial
% % y = sin(4.5*2*pi.*t);
% y = sin(40*2*pi.*t) + sin(41*2*pi.*t) + 5*sin(10*2*pi.*t);
% 
% for i=1:19
%     signal.data.trial{1}(i,:) = i.*y;
% end
% 
% data = signal.data;
% 
% save(['C:\Users\roeysc\Desktop\PNES\queries\sinus3.mat'], 'data');
% 
% % freq1 = freqAnalysisWarp('C:\Users\roeysc\Desktop\PNES\queries\sinus3.mat', [0:40], 1);
% % 
% % frequencies = freq1.freq;
% % pow = freq1.powspctrm(1,19,:);
% % pow = pow(1,:);
% % bar(frequencies, pow


%%

%  Multiple trials with small variance
for j=1:100
    
y = sin((10+2*randn-1)*2*pi.*t);
% y = sin((40+4*randn)*2*pi.*t) + sin((30+5*randn)*2*pi.*t) + 5*sin((10+6*randn)*2*pi.*t);

            for i=1:19
                signal.data.trial{j}(i,:) = 10.*y;
            end
            signal.data.time{j} = signal.data.time{1};
            
end

data = signal.data;
save(['C:\Users\roeysc\Desktop\PNES\queries\sinus1.mat'], 'data');

data = [];
signal = load('C:\Users\roeysc\Desktop\PNES\queries\sinus.mat');

for j=1:100
    
y = sin((15+2*randn-1)*2*pi.*t);
% y = sin((40+4*randn)*2*pi.*t) + sin((30+5*randn)*2*pi.*t) + 5*sin((10+6*randn)*2*pi.*t);

            for i=1:19
                signal.data.trial{j}(i,:) = 10.*y;
            end
            signal.data.time{j} = signal.data.time{1};
            
end

data = signal.data;
save(['C:\Users\roeysc\Desktop\PNES\queries\sinus2.mat'], 'data');

%% Plot the freq1, freq2 plots
% y = mean( freq1.powspctrm(:,1,:),1 );
% y = y(:);
% x = freq2.freq;
% bar(x,y);
% y = mean( freq2.powspctrm(:,1,:),1 );
% y = y(:);
% x = freq2.freq;
% hold on
% bar(x,y,'r');
% title('PowerSpectrum');
% legend('y1', 'y2');
% 
