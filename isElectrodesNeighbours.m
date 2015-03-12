function flag = isElectrodesNeighbours(cfg, electrodesList)
% isElectrodesNeighbours returns 1 if at least two elecrodes in
% electrodesList are close neighbours.
%
% INPUT
% cfg.layout: electrodes layout (default: lab_quickcap64_mcn_no_cb.mat)
% cfg.neighbourdist: distance to determine if electrodes are neighbours
%                    (in units like those used in the layout, default: 10.5 cm)
% OUTPUT
% output: 1 (at least two elecrodes are close neighbours) or 0

flag = 0;
neighboursStruct = cfg.neighboursStruct;

for elecI = 1:length(electrodesList)-1
    electrode = electrodesList(elecI);
    
    index = [];
    for i = 1:length(neighboursStruct)
        if strcmp(neighboursStruct(i).label, electrode)
            index = i; % elecI's index in the neighbours cell array
        end
    end
    if isempty(index) % if this is not a valid electrode name
        continue;
    end
    
    for elecIin = elecI+1:length(electrodesList)
        if(  ismember(electrodesList(elecIin), neighboursStruct(index).neighblabel)  )
            %if we interpolated a neighbouring electrode, dismiss this trial
            flag = 1;
            continue;
        end
    end
end