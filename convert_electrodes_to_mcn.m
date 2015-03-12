function mcn_electrodes = convert_electrodes_to_mcn(cfg, electrodes)
% convert_electrodes_to_mcn changes the names of some of the electrodes
% from those used in our lab to those used in fieldtrip and the rest of the
% world in the 10-20 mcn system.
%
% INPUT
% electrodes: cell array of electrodes names to be converted (or checked
%             for conversion)
% cfg.electrodesConversionMap: a matrix with two columns - the first with electrodes
%                    names used in the lab, the second with the names we
%                    want to use.
%
% e.g: cfg.electrodesConversionMap = fullfile(which('lab_electrodes_to_mcn_map.xlsx'));
% 
% See http://en.wikipedia.org/wiki/10-20_system_(EEG)

electrodesConversionMap = cfg.electrodesConversionMap;
electrodesConversionMap = electrodesConversionMap(2:end,:);
labColumn = 1;
mcnColumn = 2;

mcn_electrodes = electrodes;

for elecI = 1:length(electrodes)
    elecName = electrodes{elecI};
    index = 0;
    mapI = 0;
    while index == 0 && mapI < length(electrodesConversionMap)
        index = strcmpi(elecName, electrodesConversionMap{mapI+1, labColumn});
        mapI = mapI + 1;
    end
    if index == 0
        continue
    else
       mcn_electrodes(elecI) = electrodesConversionMap(mapI, mcnColumn);
       disp(['Converted ' elecName ' to ' mcn_electrodes{elecI}])
    end
end

end