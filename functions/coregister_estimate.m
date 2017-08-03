function [b] = coregister_estimate(b)
% Batch coregister 
% Walter Reilly wrote this after one gui click too many

% Usage:
%
%	b = coregister_estimate(b)
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
%      b.rundir(n).rfiles = a character array with the full paths to
%                   the .*\.nii realigned and resliced functional images
%


% First re-organize all realigned and resliced files into cell array
b.allfiles = {};
for i = 1:length(b.runs)
    b.allfiles{i} = cellstr(b.rundir(i).rfiles); 
end

% run coregister estimate 
clear matlabbatch

% initiate coreg params copied from a gui .m output
matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(b.meanfunc);
matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(b.mprage);
matlabbatch{1}.spm.spatial.coreg.estimate.other = b.allfiles';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%run it
spm('defaults','fmri');
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);



end
