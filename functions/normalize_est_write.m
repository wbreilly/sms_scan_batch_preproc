function [b] = normalize_est_write(b)
% normalize and write new volumes
%Written by Walter Reilly in sms_scan_batch_preproc

% Usage:
%
%	b = normalize_est_write(b)
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
%       b.allfiles = a character array with the full paths to all
%                   the .*\.nii coregistered images
%

% run flag 
runflag = 1;
if size(spm_select('ExtFPListRec', b.dataDir, ['^normalize.*' b.runs{1} '.*bold\.nii']), 1) > 0 % check only for first run
    if b.auto_accept
        response = 'n';
    else
        response = input('Normalization was already run. Do you want to run it again? y/n \n','s');
    end
    if strcmp(response,'y')==1
        disp('Continuing running normalization')
    else
        disp('Skipping normalization')
        runflag = 0;
    end
end

% First re-organize all realigned and resliced files into cell array
% these should be coregistered but i don't know how to check that that's
% been done yet. Important to solve. 
% b.allfiles = {};

if runflag
    for i = 1:length(b.runs)
    clear matlabbatch

    % initiate

    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = cellstr(b.mprage);
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {cellstr(b.rundir(i).rfiles)};  %b.allfiles';
    keyboard
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/Users/wbr/Documents/Matlab/spm12/tpm/TPM.nii'};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 5;
    matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'normalize_';
    
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end
end

% get file info for each run and sotre for future use
for i = 1:length(b.runs)
    b.rundir(i).nfiles = spm_select('ExtFPListRec', b.dataDir, ['^normalize*'  b.runs{i} '.*bold\.nii']);
    fprintf('%02d:   %0.0f normalized files found.\n', i, length(b.rundir(i).nfiles))
end

end % end function