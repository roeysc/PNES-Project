% massConvertTRC2MAT
% Description : This function converts all the TRC files in a give 
% directory's first subdirectory
% Input: inputDir - path to the directory
% Output: None.

function massConvertTRC2MAT(inputDir)

if (inputDir(end)~='\')
   
    inputDir(end+1) = '\';

end

% Add the eeglab path from Rachel's computer
pathdef;

subDirs = dir(inputDir);


% Go into all the directories in the given path
for i=1:length(subDirs)
   
    % Skip non-directories
    if ((~(subDirs(i).isdir))||(strcmp(subDirs(i).name,'.'))||(strcmp(subDirs(i).name,'..')))
       
        continue;
        
    end
    
    filesInSubDir = dir([inputDir subDirs(i).name '\*.TRC']);
    
    % Find all the files in each directory
    for j=1:length(filesInSubDir)
        
        autotrc2mat([inputDir subDirs(i).name '\' filesInSubDir(j).name]);
        
    end
    
end

warning('Process complete. If you would like to, please delete all TRC files');


end