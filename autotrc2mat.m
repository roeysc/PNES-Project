function [mat_file] = autotrc2mat(trc_file)
% autotrc2mat - This function automaticly converts a given trc file to mat
% by using the eeglab functions and the modificated trc plugin by yoel.
% input: trc_file - location of trc file
% output: mat_file - location of mat file
%
% NOTE: 
% 1.you must have eeglab in your matlab path and the modificated trc plugin
% installed in eeg before using this script!
% 2.it will just extract the data + add the channels , no more currently!
% 3. output signal is nelec X ntime
% Create the mat file name
mat_file = [trc_file '.mat'];
mrk_file = [trc_file '.mrk'];

% Check if trc_file exists
if (~exist(trc_file,'file'))

    error('Invalid trc file.');
    
end

here I add some more changes to we can see them!

% Define the params for reading the trc
PARAM.filename=trc_file;
PARAM.loadevents.state='no';
PARAM.loadevents.type=[];
PARAM.loadevents.dig_ch1=[];
PARAM.loadevents.dig_ch1_label=[];
PARAM.loadevents.dig_ch2=[];
PARAM.loadevents.dig_ch2_label=[];
PARAM.chan_adjust_status=0;
PARAM.chan_adjust=[];
PARAM.chans=[];


% Read the trc

[EEGOUT] = pop_readtrc(PARAM);

% Add the channels

[EEGOUT] = pop_chanedit(EEGOUT,'load',{[trc_file '.lbl'] 'filetype' 'sph'});

% Fix the data to our format
data = EEGOUT.data;
sig = double(floor(data*100)/100); % Drop places 3+4 after point as they are nonsense

% Load the markers (Assumes the cartool standard format)
raw_mrk = textread(mrk_file, '%s', 'delimiter', '\n');
raw_mrk = raw_mrk(2:end);
mrk = regexp(raw_mrk,'\d*','match');
mrk = [{cellfun(@(x) str2num(x{1}),mrk)} {cellfun(@(x) str2num(x{2}),mrk)}];
notes = regexp(raw_mrk, '(?<=")[^"]+', 'match');
mrk = [mrk {cellfun(@(x) x,notes)}]; 

chan = [];

this is a line I changed for this example

% matlab 2009b has problems with creating the channels as strings array
% with different sizes. Hence the following condition:
if strcmp(version('-release'),'2009b')
        for i =1:length(EEGOUT.chanlocs)
            chan{i} =  EEGOUT.chanlocs(i).labels;
            chan{i} = regexp(chan{i},'\w+[+|-]*','match');
        end
else
        for i =1:length(EEGOUT.chanlocs)
            chan = [ chan ; EEGOUT.chanlocs(i).labels];
        end
        chan = cellstr(chan);    
end

srate = EEGOUT.srate;

% Write the matlab
save(mat_file,'sig','chan','mrk','srate','-v7.3');

end