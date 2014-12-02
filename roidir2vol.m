function roivol = roidir2vol(roidir)

rois = dir(fullfile(roidir,'*.nii'));
nroi = length(rois);
names = stripext({rois.name}');
cwd = pwd;
cd(roidir);
roivol = SPMVolume({rois.name},[],'metasamples',struct('names',{names}));
cd(cwd);
