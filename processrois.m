% Master function for ROI preparation. 
%
% processrois(rootdir,cons,unsmpath)
function processrois(rootdir,cons,unsmpath)

% append hdr to get to the masked volume. cd into directory to get ROIs
% for masking
ncon = length(cons);

% thresholding by relevant contrast and by unsmoothed v
% baseline (for voxel ranking)
roipaths = {};
for c = 1:ncon
    conhits = dir(fullfile(rootdir,[cons{c} '*.hdr']));
    assert(length(conhits)==1,'need exactly one hit for %s',cons{c});
    % assume roidir name is same as mask name 
    [junk,constr,ext] = fileparts(conhits(1).name);
    roidir = fullfile(rootdir,constr);
    rois = [dir(fullfile(roidir,'*.nii')); ...
        dir(fullfile(roidir,'*.hdr')); ...
        dir(fullfile(roidir,'*.nii.gz'))];
    nrois = length(rois);
    assert(nrois>0,'no rois found in %s',roidir);
    % make full paths
    rois = arrayfun(@(x)fullfile(rootdir,constr,rois(x).name),...
        1:nrois,'uniformoutput',false);
    paths = thresholdrois(fullfile(rootdir,conhits(1).name),rois);
    roipaths = [roipaths; paths];
end

% analyse overlap
fighand = visualiseroioverlap(roipaths);
printstandard(fullfile(rootdir,'diagnostic_overlaps'),fighand);
close(fighand);

% make bilateral versions of ROIs (with overwrite)
birois = createbilateralrois(roipaths,true);
roipaths = [roipaths(:); birois(:)];

% add to Volume instances - one for smooth, one for unsmooth. These then
% get imported in a minimalistic AA module.
nroi = length(roipaths);
names = cell(nroi,1);
for r = 1:nroi
    [junk,names{r},junk] = fileparts(roipaths{r});
end
roivol = MriVolume(roipaths,[],'metasamples',struct('names',{names}));
save(fullfile(rootdir,'roivol.mat'),'roivol');

if ~ieNotDefined('unsmpath')
    % re-write with intensity values from unsmoothed map
    roipaths_unsmooth = thresholdrois(unsmpath,roipaths,...
        'thresholded_unsmoothvbase');
    roivol = MriVolume(roipaths_unsmooth,[],'metasamples',...
        struct('names',{names}));
    save(fullfile(rootdir,'roivol_unsm.mat'),'roivol');
end
