% Returns the voxel coordinates for the current position in the
% SPM results viewer.
% J Carlin 10/6/2011

%function xyz_vox = mm_to_vox(hReg,xSPM)
function xyz_vox = mm_to_vox(hReg,xSPM)

%hReg = findobj('Tag','hReg'); % get results figure handle
xyz_mm = spm_XYZreg('GetCoords',hReg); % get mm coordinates for current locationassignin('base','xyz_mm',xyz_mm); % puts xyz_mm in base workspace
xyz_vox = xSPM.iM*[xyz_mm;1]; %evalin('base','xSPM.iM*[xyz_mm;1]'); % avoid passing xSPM explicitly
xyz_vox = xyz_vox(1:3);
