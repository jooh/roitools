% create spherical rois in native space based on a set of coordinates
% specified in MNI space.
%
% INPUTS:
% subdir: full path to directory where rois go. Gets created if necessary.
% masks: a struct array with the fields name (char) and mnicoords (1x3
%   numeric).
%
% NAMED INPUTS:
% normpath: full path to seg_sn.mat file from spm normalisation
% maskpath: full path to a brain mask nifti in native space
% masksize: size of sphere in voxels
% overwrite: true or false
%
% makecoordrois(subdir,masks,varargin)
function makecoordrois(subdir,masks,varargin)

getArgs(varargin,{'normpath','','maskpath','','masksize',100,...
    'overwrite',1});

sl = Searchlight(maskpath,'nvox',masksize);

nmask = length(masks);
outpaths = cell(nmask,1);
for m  = 1:nmask
    thismask = masks(m);
    voxcoord = round(spm_get_orig_coord(thismask.mnicoords,normpath,...
        maskpath))';
    if ~any(voxcoord(1)==sl.vol.xyz(1,:) & voxcoord(2)==sl.vol.xyz(2,:) & voxcoord(3)==sl.vol.xyz(3,:))
        % that coordinate is outside the brain mask, so need to find the
        % closest match
        normcoords = bsxfun(@minus,sl.vol.xyz,voxcoord);
        distances = sqrt(sum(normcoords.^2,1));
        [mind,minind] = min(distances);
        fprintf('coordinate outside mask, shifting by %.1fmm.\n',mind);
        voxcoord = sl.vol.xyz(:,minind);
    end

    roi = ind2logical([1 sl.vol.nfeatures],sl.mapcoords(voxcoord));
    outpaths{m} = fullfile(subdir,[thismask.name '.nii']);
    if exist(outpaths{m},'file')~=0
        if overwrite
            fprintf('overwriting existing roi. \n');
        else
            fprintf('skipping existing roi: %s. \n',outpaths{m});
            continue;
        end
    end
    sl.vol.data2file(roi,outpaths{m});
    fprintf('wrote roi: %s. \n',outpaths{m});
end

% bilateral variants
birois = createbilateralrois(outpaths,overwrite);
