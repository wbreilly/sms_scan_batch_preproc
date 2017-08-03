function [b] = normalize_estimate(b)

% normalize estimate. Written by Walter Reilly

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
%       Output:
% 
%       b.def         = deformation field for noramlize write

ragedir   = fullfile(b.dataDir,'002_mprage_sag_NS_g3');


% run flag 
runflag = 1;
if size(spm_select('FPListRec', ragedir, ['^y.*' '.*.nii']), 1) > 0 
    if b.auto_accept
        response = 'n';
    else
        response = input('Normalize estimate was already run. Do you want to run it again? y/n \n','s');
    end
    if strcmp(response,'y')==1
        disp('Continuing running normalize estimate')
    else
        disp('Skipping normalize estimate')
        runflag = 0;
    end
end


if runflag
    % initiate 
    matlabbatch{1}.spm.spatial.normalise.est.subj.vol = cellstr(b.mprage);
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.tpm = {'/Users/wbr/Documents/Matlab/spm12/tpm/TPM.nii'};
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.samp = 3;
    
    
    % run
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);

end % end runflag


if size(spm_select('FPListRec', ragedir, ['^y.*' '.*.nii']), 1) > 0
    b.def = spm_select('FPListRec', ragedir, ['^y.*' '.*.nii']);
    fprintf('Found deformation field!') 
end

end





