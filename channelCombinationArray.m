function cmb = channelCombinationArray(channelsPath)
% channelCombinationArray recieves cell vectors channelsA and channelsB of
% strings, and returns all possible combinations of them
%
% INPUT
%               channelsPath: path to xlsx file containing channels labels
%
%
% OUTPUT
%
%   e.g. cmb =  channelCombinationArray('C:\Users\roeysc\Desktop\PNES\hippocampus_rois.txt')
%

[~,~,channels] = xlsread(channelsPath);
channels = channels(:,1);
% get rid of NaNs
indices = [];
for i = 1:length(channels)
    if(isnan(channels{i}))
       indices(end+1) = i;  
    end
end
channels(indices) = [];

pairsNum = sum(length(channels)-1 : -1 : 1);
cmb = cell(pairsNum,2);

idx = 1;
for i = 1:length(channels)-1
    for j = i+1:length(channels)
        cmb(idx,:) = {channels{i}, channels{j}};
        idx = idx + 1;
    end
end

end