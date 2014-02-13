% make an ROI of the blob at the current SPM8 results viewer position.
%
% spm2roi(nvox,hReg,xSPM)
function spm2roi(nvox,hReg,xSPM)

% get current mm centroid
peak = round(mm_to_vox(hReg,xSPM)');
% get contrast data
dims = xSPM.Vspm(1).dim;
xyz = spm_read_vols(xSPM.Vspm(1));
if numel(xSPM.Vspm)>1
    fprintf('overlaying on first of %d volumes in contrast.\n',...
        numel(xSPM.Vspm));
end

% remove any nans
mask = ~isnan(xyz);

% bring up the statistical map in gray
F = figure(991204);
set(F,'name','spm2roi viewer');
xyzstack = makeimagestack(xyz);
xyzim = intensity2rgb(xyzstack,gray);
imshow(xyzim);
hold on;

% keep tweaking ROI size
done = false;
while ~done
    roicoords = resizeRoi(peak,xyz,nvox,mask);

    % make mask (plug in stats)
    inds = sub2ind(dims,roicoords(:,1),roicoords(:,2),roicoords(:,3));
    roimask = zeros(dims);
    alphamask = roimask;
    roimask(inds) = xyz(inds);
    alphamask(inds) = 1;
    fprintf('max stat: %.3f\n',max(xyz(inds)));
    fprintf('min stat: %.3f\n',min(xyz(inds)));

    % show the masked voxels in jet
    roistack = makeimagestack(roimask);
    roiim = intensity2rgb(roistack,jet);
    alphastack = makeimagestack(alphamask);
    ih = imshow(roiim);
    set(ih,'alphadata',alphastack);

    % get a name (or custom command) from user
    roiname = input('roi name: ','s');
    if isempty(roiname)
        break;
    end
    switch roiname(1)
        case {'-','+'}
            % resize ROI and recompute
            assert(length(roiname)>1,'bad roi name: %s',roiname);
            modifier = str2num(roiname(2:end));
            if strcmp(roiname(1),'+')
                nvox = nvox + modifier;
            else
                nvox = nvox - modifier;
            end
            assert(nvox>0,'out of voxels');
            fprintf('new size: %d\n',nvox);
        otherwise
            % we're done
            done = true;
    end
    % remove the overlay (for re-drawing on next iteration)
    delete(ih);
end

if ~done
    % don't attempt to save if you left the ROI name blank
    fprintf('no roi saved\n');
    return
end

% write out mask (to current directory)
newV = xSPM.Vspm(1);
newV.fname = [roiname '.nii'];
spm_write_vol(newV,roimask);
fprintf('saved roi %s\n',newV.fname);
