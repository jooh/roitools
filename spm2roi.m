% make an ROI of the blob at the current SPM8 results viewer position. A
% convenient wrapper for coords2roi (which wraps Niko's resizeRoi in turn).
%
% INPUTS:
% nvox: number of voxels for ROI
% hReg, xSPM: SPM results viewer variables. These will be available in your
% base workspace if you have a result open.
%
% spm2roi(nvox,hReg,xSPM)
function spm2roi(nvox,hReg,xSPM)

% get current mm centroid
peak = round(mm_to_vox(hReg,xSPM)');

if numel(xSPM.Vspm)>1
    fprintf('overlaying on first of %d volumes in contrast.\n',...
        numel(xSPM.Vspm));
end

coords2roi(nvox,peak,xSPM.Vspm(1));
