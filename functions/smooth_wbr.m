function [b] = smooth_wbr(b)

% Writes smoothed volumes 
% written by Walter Reilly to save a lot of time

% Usage:
%
%	b = smooth_wbr(b)
%   
%   input arguments:
%
%	b = memolab qa batch structure containing the fields:
%
%       b.dataDir     = fullpath string to the directory where the functional MRI data
%                       is being stored
%
%       b.runs        = cellstring with IDs for each functional time series
%
%       b.auto_accept = a true/false variable denoting whether or not the 
%                       user wants to be prompted
%
%       b.rundir      = a 1 x n structure array, where n is the number of
%                       runs, with the fields:
% 
%       b.rundir.nfiles = all the normalized volumes
% 
%       Output:
% 
%       b.rundir.smfiles  = smoothed volumes

% run flag 
runflag = 1;
if size(spm_select('ExtFPListRec', b.dataDir, ['^smoothed*' b.runs{1} '.*bold\.nii']), 1) > 0 
    if b.auto_accept
        response = 'n';
    else
        response = input('Smoothie was already run. Do you want to run it again? y/n \n','s');
    end
    if strcmp(response,'y')==1
        disp('Continuing smoothie')
    else
        disp('Skipping smoothie')
        runflag = 0;
    end
end

if runflag
    for i = 1:length(b.runs)
        clear matlabbatch
        
        %initiate
        % if normalizing, bring back .nfiles
        %matlabbatch{1}.spm.spatial.smooth.data = cellstr(b.rundir(i).nfiles);
        matlabbatch{1}.spm.spatial.smooth.data = cellstr(b.rundir(i).sfiles);
        matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 'smoothed_';
        
        % run
        spm('defaults','fmri');
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch);
    
        % print success
        b.rundir(i).smfiles = spm_select('ExtFPListRec', b.dataDir, ['^smooth.*'  b.runs{i} '.*bold\.nii']);
        fprintf('%02d:   %0.0f smoothed files found.\n', i, length(b.rundir(i).smfiles))
           
    end % end i b.runs
end % end if runflag

end