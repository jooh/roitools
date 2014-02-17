% make an ROI of the blob centered on voxel coordinate in coords. Wraps
% Niko's resizeRoi.
%
% INPUTS:
% nvox: number of voxels for ROI
% coords: [x y z], in 1-based voxel indices, not mm
% vol: SPM volume or a char array pointing to a nifti.
%
% coords2roi(nvox,coords,vol);
function coords2roi(nvox,coords,vol);

if ischar(vol)
    vol = spm_vol(vol);
end

% get contrast data
dims = vol.dim;
xyz = spm_read_vols(vol);

% bring up the statistical map in gray
F = figure(991204);
hold off;
set(F,'name','spm2roi viewer');
xyzstack = makeimagestack(xyz);
xyzim = intensity2rgb(xyzstack,gray(1024));
imshow(xyzim);
hold on;

% keep tweaking ROI size
done = false;
while ~done
    roicoords = resizeRoi(coords,xyz,nvox);

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
    roiim = intensity2rgb(roistack,jet(1024));
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
    delete(ih);
    return
end

% write out mask (to current directory)
newV = vol;
newV.fname = [roiname '.nii'];
spm_write_vol(newV,roimask);
fprintf('saved roi %s\n',newV.fname);
