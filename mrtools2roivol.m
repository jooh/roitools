% Convert a set of MrTools ROIs to an roivol instance for further pilab
% processing.
%
% INPUT     DEFAULT     DESCRIPTION
% v         -           mlr view.
% roinames  -           cell array of ROI names
% maskvol   -           MriVolume instance or sub-class thereof.
%
% roivol = mrtools2roivol(v,roinames,maskvol)
function roivol = mrtools2roivol(v,roinames,maskvol)

roivol = [];
diagnostic = [];

nroi = numel(roinames);
roidir = viewGet(v,'roidir');

alreadyloaded = viewGet(v,'roinames');

gnum = viewGet(v,'groupnum','MotionComp');
snum = viewGet(v,'currentscan');


rois = sparse(nroi,maskvol.nfeatures);
rc = 0;
for r = 1:nroi
    loaded = false;
    if isempty(intersect(alreadyloaded,roinames{r}))
        v = loadROI(v,roinames{r});
        loaded = true;
    end
    % TODO: what happens if an ROI is missing?
    rnum = viewGet(v,'roinum',roinames{r});
    if isempty(rnum)
        logstr('could not find ROI %s, skipping.\n',roinames{r})
        continue;
    end
    rc = rc+1;
    % scan coordinates
    coords = getROICoordinates(v,rnum,snum,gnum,'straightXform',1);
    dims = viewGet(v,'scandims');
    % go to 3D
    mask = coord2mat(coords,dims);
    % get rid of voxels outside maskvol
    mask(~maskvol.mask) = false;
    % and plug into the roi vector
    rois(rc,:) = mask(maskvol.linind);
    if loaded
        v = viewSet(v,'deleteroi',rnum);
    end
    names(rc) = roinames(r);
end
rois = rois(1:rc,:);
% finally, build the ROI volume
roivol = feval(class(maskvol),rois,maskvol,'metasamples',struct(...
    'names',{names(:)}));
