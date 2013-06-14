% parse a set of ROI names,matching up pairs of ROIs prefixed with r_ and
% l_ into an ROI with no prefix. If we can find only one ROI we make an roi
% regardless. If outpath already exists (e.g. if you are re-running the
% script), we crash unless overwrite is true.
%
% (generalised version of makeROIsBilateral from proj/johan)
%
% newrois = createbilateralrois(roipaths,[overwrite])
function newrois = createbilateralrois(roipaths,overwrite)

if ieNotDefined('overwrite')
    overwrite = false;
end

% parse into ROI struct
for r = 1:length(roipaths);
    [parentdir,fn,ext] = fileparts(roipaths{r});
    % ignore ROIs that don't have laterality (ie no l or r)
    % 1 for left, 2 for right, empty for other
    if ~any(strcmp(fn(1:2),{'l_','r_'}))
        fprintf('skipping non-lateral ROI: %s\n',roipaths{r});
        continue
    end
    % strip leading to make bilateral name
    name = fn(3:end);
    roi(r) = struct('fullpath',roipaths{r},'name',name,...
        'parentdir',parentdir,'extension',ext);
end

newrois = {};
% Use pop approach to gradually whittle down struct array of unilateral roi
while length(roi) > 0
    % pop first in list
    current = roi(1);
    roi(1) = [];
    % any others by that name?
    others = find(strcmp(current.name,{roi.name}));
    switch length(others)
        case 0
            % unilateral roi - just rename and save
            outpath = fullfile(current.parentdir,...
                [current.name current.extension]);
            if exist(outpath,'file')
                assert(overwrite,'bilateral ROI already exists: %s',...
                    outpath);
                fprintf('overwriting existing file... ');
            end
            newrois{end+1} = outpath;
            success = copyfile(current.fullpath,outpath);
            assert(success,'copy failed (from %s to %s)',...
                current.fullpath,outpath);
            fprintf('saved unilateral ROI: %s\n',outpath);
        case 1
            % bilateral roi - combine and save
            % pop the hit off the list
            next = roi(others);
            roi(others) = [];
            % load 
            currV = spm_vol(current.fullpath);
            nextV = spm_vol(next.fullpath);
            spm_check_orientations([currV nextV]);
            currxyz = spm_read_vols(currV);
            nextxyz = spm_read_vols(nextV);
            assert(~any(currxyz(:)~=0 & nextxyz(:)~=0),...
                'ROIs already overlap: %s and %s',current.fullpath,...
                next.fullpath);
            nextmask = nextxyz~=0;
            % update current ROI with non-zero voxels from next
            currxyz(nextmask) = nextxyz(nextmask);
            % write out in current's directory, with current's header
            outpath = fullfile(current.parentdir,...
                [current.name current.extension]);
            if exist(outpath,'file')
                assert(overwrite,'bilateral ROI already exists: %s',...
                    outpath);
                fprintf('overwriting existing file... ');
            end
            newrois{end+1} = outpath;
            currV.fname = outpath;
            spm_write_vol(currV,currxyz);
            fprintf('saved bilateral ROI: %s\n',outpath);
        otherwise
            % more than 1 other suggests ambiguous names
            error('more than 2 rois matching %s',current.name)
    end
end
