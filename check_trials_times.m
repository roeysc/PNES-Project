% Check trials times

for i = 1:length(rawData.trial)
   disp(datestr(datevec(rawData.labfield.trialStartTime{i})));
end

disp('Now next')
for i = 1:length(rereferencedData.trial)
   disp(datestr(datevec(rereferencedData.labfield.trialStartTime{i})));
end