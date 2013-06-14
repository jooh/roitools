% threshold a set of binary ROIs in roidir by the (masked) intensity volume
% in maskpath, and save the in-ROI voxels of the mask to outdir (a subdir
% to where roi currently is). This would typically be the first step of ROI
% processing after drawing the ROI in FSLView.
%
% outfiles = thresholdrois(maskpath,rois,outdir)
function outfiles = thresholdrois(maskpath,rois,outdir)

maskV = spm_vol(maskpath);
mask = spm_read_vols(maskV);
mask(isnan(mask)) = 0;

if ~exist('outdir','var') || isempty(outdir)
    outdir = 'thresholded';
end

outfiles = {};
for roi = rois(:)'
    roistr = roi{1};
    [roidir,fn,ext] = fileparts(roistr);
    if strcmp(ext,'.gz')
        % unzip gzips
        newroipath = gunzip(roistr);
        % gunzip likes to return cell arrays sometimes
        if iscell(newroipath)
            newroipath = newroipath{1};
        end
        delete(roistr);
        roistr = newroipath;
        [path,fn,ext] = fileparts(roistr);
    end
    roiV = spm_vol(roistr);
    roi = spm_read_vols(roiV);
    roi(isnan(roi)) = 0;
    maskedroi = mask;
    % to preserve float in mask, we set values outside the ROI to 0
    maskedroi(roi==0) = 0;
    roiV.fname = fullfile(roidir,outdir,[fn ext]);
    mkdirifneeded(fullfile(roidir,outdir));
    roiV.dt = maskV.dt;
    spm_write_vol(roiV,maskedroi);
    outfiles = [outfiles; {roiV.fname}];
end
