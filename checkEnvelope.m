function  checkEnvelope(filteredData, envelopeData, trial)
% checkEnvelope plots filtered data and its envelope in all trials
%
%   e.g.: checkEnvelope(filteredData, envelopeData, 1)

roisNum = length(filteredData.label);
height = 0;

for roiI = 1:roisNum
    if mod(roiI,10) == 1
        figure
        hold on
        height = 0;
        title(['Normalized Data and Envelope, trial ' num2str(trial)])    
        
            if length(filteredData.label) < roiI+9
                tmp_labels = filteredData.label(roiI:end);
            else
                tmp_labels = filteredData.label(roiI:roiI+9);
            end
            set(gca,'YTick',0:2:length(tmp_labels)*2-2);
            set(gca,'YTickLabel',tmp_labels);
            axis([filteredData.time{trial}(1), filteredData.time{trial}(end), -1.5, 19.5]);
    end
    
    plot(filteredData.time{trial},filteredData.trial{trial}(roiI,:)./max(filteredData.trial{trial}(roiI,:)) + height, 'b')
    plot(envelopeData.time{trial},envelopeData.trial{trial}(roiI,:)./max(filteredData.trial{trial}(roiI,:)) + height,'r','linewidth', 2)

    height = height + 2;

%     if mod(roiI,5) == 0 ||
%             if length(filteredData.label) < roiI+4
%                 tmp_labels = filteredData.label(roiI:end);
%             else
%                 tmp_labels = filteredData.label(roiI:roiI+4);
%             end
%             set(gca,'YTick',0:2:length(tmp_labels)*2);
%             set(gca,'YTickLabel',tmp_labels);
%         end

end

figure
hold all
for roiI = 1:roisNum
    plot(envelopeData.time{trial},envelopeData.trial{trial}(roiI,:))
end

end
