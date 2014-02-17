% show a colour matrix indicating overlap between pairs of rois masks in
% roipaths.
%
% fighand = visualiseroioverlap(roipaths)
function F = visualiseroioverlap(roipaths)

if iscell(roipaths)
    % SPM can't cope with cell arrays in a sensible manner
    roipaths = char(roipaths);
end

Vs = spm_vol(roipaths);
masks = spm_read_vols(Vs) > 0;
% make 2D
anyvox = sum(masks,4) > 0;
[x,y,z] = ind2sub(size(anyvox),find(anyvox));
clear masks
mdata = spm_get_data(Vs,[x y z]');
overlaps = pdist(mdata,@overlapdist);
F = figure;
set(F,'position',[0 0 800 600]);
imagesc(squareform(overlaps),[0 max([1; overlaps(:)])]);
colorbar;
nroi = size(roipaths,1);
roinames = cell(nroi,1);
for r = 1:nroi
    [junk,roinames{r},junk] = fileparts(roipaths(r,:));
    roinames{r} = strrep(roinames{r},'_',' ');
end
set(gca,'dataaspectratio',[1 1 1],'ytick',1:nroi,...
    'yticklabel',roinames,'xtick',1:nroi,'xticklabel',roinames,...
    'tickdir','out');
rotateXLabels(gca,45);
box off
