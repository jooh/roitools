% construct a pilab roivol with one region for each NII file encountered in
% roidir.
%
% roivol = roidir2vol(roidir)
function roivol = roidir2vol(roidir)

rois = dir(fullfile(roidir,'*.nii'));
nroi = length(rois);
names = stripextension({rois.name}');
cwd = pwd;
cd(roidir);
roivol = SPMVolume({rois.name},[],'metasamples',struct('names',{names}));
cd(cwd);
