function orthogonalData = getOrthogonalSignals(cfg, data)
% getOrthogonalSignals returns the data structure with orthogonal signals
% in all ROIs, orthogonal to the signal in the specified cfg.seedRoi (which
% is the number of that roi).
%
% data is the output of getAtlasFft
% 
% cfg = [];
% cfg.seedRoi = 36;
% orthogonalData_to36 = getOrthogonalSignals(cfg, data_fft)

orthogonalData = data;
seedRoi = cfg.seedRoi;
roisNum = length(data.label);
    

for foiI = 1:length(data.freq);
    
    % take the TC of the seed (this is the time course of the FFT)
    LY = squeeze(data.fourierspctrm(:,seedRoi,foiI,:)); % TC of the seed (trial X time)
    X = squeeze(data.fourierspctrm(:,:,foiI,:)); % TC of all ROIs (trial X ROI X time)

    AllorthL = zeros(size(X));

    
    conjNormL = conj(LY)./abs(LY);
    conjNormX = conj(X)./abs(X);
    
    % Loop over all ROIs and perform orthogonalization to the seed TC
    
    for roiI = 1:roisNum
        AllorthL(:,roiI,:) = imag(squeeze(X(:,roiI,:)) .* conjNormL(:,:));
        
        orthogonalData.fourierspctrm(:,:,foiI,:) = AllorthL;
    end
    
end

end