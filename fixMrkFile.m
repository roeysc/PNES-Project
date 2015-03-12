% Convert times to samples
dateStartRecordingSerial = datenum('22.05.2014 17:11:08', 'dd.mm.yyyy hh:MM:ss'); % TODO: Check the real time of recording (17:11:08:01)
srate = 2048; % Hz

% Read xls file
[~,~,xlsfile] = xlsread('C:\Users\roeysc\Desktop\RoeyEEG\SEGMENTS.xlsx');

% Open file to write to
fid = fopen('C:\Users\roeysc\Desktop\RoeyEEG\mrkfile.txt','wt');
fprintf(fid, 'TL02\n');
for i = 1:length(xlsfile)
    mrkStr = xlsfile{i,1};
    dateStr = ['22.05.2014 ', xlsfile{i,2}];
    dateSerial = datenum(dateStr ,'dd.mm.yyyy hh:MM:ss');
    dateSerial = dateSerial - dateStartRecordingSerial; % this is in days since start of the recording
    
    % every 256 samples are supposed to be 1 second
    sample = floor(dateSerial*(3600*24)*srate); % in each day there are 3600*24 seconds, and we get the number of samples by multiplying with the srate
    if mod(i,2)
        sample = sample + srate*0.5; % this will move the first marker of each pair 0.5 seconds forward (to make sure we don't take artifacts due to the poor temporal resolution of this poor method
    end
    fprintf(fid,'%s \t', [num2str(sample)]); % this is better than using %f or %g, because it's not limited
    fprintf(fid,'%s \t', [num2str(sample)]);
    fprintf(fid,'"%s"\n', [mrkStr]);
end
fclose(fid);