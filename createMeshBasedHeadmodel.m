function createMeshBasedHeadmodel(cfg, segmentedMRI) 
% CREATEMESHBASEDHEADMODEL creates a realistic headmodel and a mesh structure for EEG source analysis
%
% INPUT: segmentedMRI - full path of patient's segmented MRI file (as
%                                                 obtained from segmentMRI.mat) in bss format (brain skull scalp)
%                cfg.method       - the head model method (singlesphere or openmeeg), see "ft_prepare_headmodel". Default: singlesphere
%                                                 NOTE: openmeeg now works only on Linux
%                cfg.segment_type - bss or tpm, according to the method used. Default: bss
%
% OUTPUT: no output, but meshes and headmodel are saved in a subdirs of the segmentedMRI directory.
%
% NOTE: full fieldtrip version is needed for the iso2mesh toolbox. 
%              OPENMEEG is needed for creating the headmodel in openmeeg method.
%
% e.g.: % createMeshBasedHeadmodel([], 'C:\Users\roeysc\Desktop\PNES\MRI\realigned\segmented\bss_segmented_pGR1992.mat')

%% Define default segmentation method if necessary
if ~exist('cfg')
    cfg.method = 'singlesphere';
    cfg.segmentation_type = 'bss';
else
    if ~isfield('cfg','method')
        cfg.method = 'singlesphere';
    end
    if ~isfield('cfg','segmentation_type')
        cfg.segmentation_type = 'bss';
    end
end

%% take path and patient name for segmentedMRI
[ segmentedMRIdir, fileName ] = fileparts(segmentedMRI);
    index = find(fileName == '_'); % TODO: this is a terrible way to find it.
    patientName = fileName (index(end)+1:end); %take only the patient's name
%% Load Segmented MRI File
segmentedMriFile = segmentedMRI;
data = load(segmentedMRI);
if strcmp(cfg.segmentation_type, 'bss')
    segmentedMRI = data.bss_segmentedmri; % in  mm
elseif strcmp(cfg.segmentation_type, 'tpm')
    segmentedMRI = data.tpm_segmentedmri; % in  mm
end
segmentedMRI = ft_convert_units(segmentedMRI,'cm'); % Convert to cm
clear data;

meshcfg.method = 'iso2mesh';
meshcfg.numvertices = 10000;   % We'll decimate later - this gives nicer results
meshcfg.tissue={'brain','skull','scalp'};
bnd = ft_prepare_mesh(meshcfg,segmentedMRI);

% Decimate to a 1000, 2000, 3000 node mesh (scalp, skull, brain)
[bnd(1).pnt, bnd(1).tri] = meshresample(bnd(1).pnt, bnd(1).tri, 1000/size(bnd(1).pnt,1));
[bnd(2).pnt, bnd(2).tri] = meshresample(bnd(2).pnt, bnd(2).tri, 2000/size(bnd(2).pnt,1));
[bnd(3).pnt, bnd(3).tri] = meshresample(bnd(3).pnt, bnd(3).tri, 3000/size(bnd(3).pnt,1));

% Fix meshes intersections
decouplesurf(bnd);                

% Fix meshes self-intersections using the iso2mesh toolbox
% (available in fieldtrip's full version)
for ii = 1:3
    [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'dup');
    [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'isolated');
    [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'deep');
    [bnd(ii).pnt, bnd(ii).tri] = meshcheckrepair(bnd(ii).pnt, bnd(ii).tri, 'meshfix');
end

% Plot meshes to check
figure; ft_plot_mesh(bnd(1));
figure; ft_plot_mesh(bnd(2));
figure; ft_plot_mesh(bnd(3));

% Save bnd
if ~exist([segmentedMRIdir, 'mesh'], 'dir')
    mkdir(segmentedMRIdir, 'mesh')
end
save([segmentedMRIdir '\mesh\bss_mesh_' patientName '.mat'], 'bnd');

%% Prepare Head Model
tmpcfg = [];
tmpcfg.method = cfg.method; % Default is 'singlesphere'
vol = ft_prepare_headmodel(tmpcfg, segmentedMRI); % same units as segmentedMRI (cm)
vol = ft_convert_units(vol,'cm');

if ~exist([segmentedMRIdir, 'headmodel'], 'dir')
    mkdir(segmentedMRIdir, 'headmodel')
end

save([segmentedMRIdir '\headmodel\openmeeg_headmodel_' patientName '.mat'], 'vol');

end