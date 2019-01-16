function [b] = normalize_write(b)

% Writes normalized volumes 
% written by Walter Reilly to save a lot of time

% Usage:
%
%	b = normalize_estimate(b)
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
%       b.mprage      = path to the mprage 
% 
%       b.def         = deformation field for noramlize write
% 
%       Output:
% 
%       b.rundir.nfiles  = normalized volumes

%% 
% grab slice time files 
% only required when jumping into this step from native space pipeline
for i = 1:length(b.runs)
    b.rundir(i).sfiles = spm_select('ExtFPListRec', b.dataDir, ['^slicetime.*'  b.runs{i} '.*bold\.nii']);
    fprintf('%02d:   %0.0f slicetime files found.\n', i, length(b.rundir(i).sfiles))
end


% get the def field created in normalize_estimate.m
ragedir   = fullfile(b.dataDir,'002_mprage_sag_NS_g3');
if size(spm_select('FPListRec', ragedir, ['^y.*' '.*.nii']), 1) > 0
    b.def = spm_select('FPListRec', ragedir, ['^y.*' '.*.nii']);
    fprintf('Found deformation field!') 
else fprintf('No def!!')
end


%%

% run flag 
runflag = 1;
if size(spm_select('ExtFPListRec', b.dataDir, ['^normalized*' b.runs{1} '.*bold\.nii']), 1) > 0 
    if b.auto_accept
        response = 'n';
    else
        response = input('Normalize write was already run. Do you want to run it again? y/n \n','s');
    end
    if strcmp(response,'y')==1
        disp('Continuing running normalize write')
    else
        disp('Skipping normalize write')
        runflag = 0;
    end
end

if runflag
    for i = 1:length(b.runs)
        clear matlabbatch
        
        %initiate
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = cellstr(b.def);
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = cellstr(b.rundir(i).sfiles);
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'normalized_';
        
        % run
        spm('defaults','fmri');
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch);
    
        % print success
        b.rundir(i).nfiles = spm_select('ExtFPListRec', b.dataDir, ['^normalize.*'  b.runs{i} '.*bold\.nii']);
        fprintf('%02d:   %0.0f normalized files found.\n', i, length(b.rundir(i).nfiles))
           
    end % end i b.runs
end % end if runflag

end
