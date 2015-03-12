function mriRealign( inputDir )
% This function realigns MRI files in hdr format and fits it to the SPM coordinate
% system (that is, NMI).
% INPUT: inputDir - a directory containing all MRI files
%
% OUTPUT: No output. Realigned MRI files are saves to a subdirectory called "realigned".
%
% Follow the instructions in the command window to choose:
%   - 'a' (anterior commissure)
%   - 'p' (posterior commissure)
%   - 'z' (a point on the positive (upper) z axis)
% and hit 'q' to finish and automatically save the realigned MRI file.
%
% TIPS: use '+','-' to brighten the display.
%              AC and PC are easily horiznotal images are 

%% backslah fix
if (inputDir(end)~='\')
    inputDir(end+1) = '\';
end

%% Load, Realign and save each MRI file
filesInDir = dir([inputDir '\*.hdr']);

for i=1:length(filesInDir)
    % read MRI
    fileName = filesInDir(i).name;

    mriFile = ft_read_mri( [inputDir fileName] ); % CHECKME: WE HAVE TO FIND THE TEMPLATE MRI FILE (MNI)

    
    cfg.method = 'interactive'; % 'interactive' or 'landmark';
    cfg.coordsys = 'spm';
    cfg.parameter = 'anatomy';
    [mriReal] = ft_volumerealign(cfg, mriFile);

    % save mri file
    if ~exist([inputDir 'realigned'], 'dir')
        mkdir(inputDir, 'realigned')
    end

    fileName = fileName(1:end-4);% remove the ".hdr" extansion
    mriReal = ft_convert_units(mriReal,'cm');
    save([inputDir 'realigned\' fileName] ,'mriReal');
end

end