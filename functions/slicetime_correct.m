function [b] = slicetime_correct(b)
% slice time correct for Rang lab multiband sequence 
% written by Walter Reilly to pre proc the dirty data 
%   Usage:
%
%	b = slicetime_correct(b)
%   
%   input arguments:
%
%	b = memolab qa batch structure containing the fields:
%
%       b.runs      = cellstring with the name of the directories containing
%                     each functional run
%
%       b.dataDir   = fullpath string to the directory where the functional MRI data
%                     is being stored
%
%       b.rundir    = a 1 x n structure array, where n is the number of
%                     runs
%
%       b.scriptdir = fullpath string to the directory where the memolab
%                     scripts
%
%   output arguments:
%
%   b = memolab qa batch structure containg the new fields:
%
%       b.rundir(n).sfiles = a character array containg the full paths to
%                           the recently slice time corrected .*\.nii files
%
%
% See also: find_nii, spm_dicom_headers, spm_dicom_convert

% Check if slice time correction was already run and if so, whether it should be run
% again
runflag = 1;

if size(spm_select('ExtFPListRec', b.dataDir, ['^slicetime.*'  b.runs{1} '.*bold\.nii'],1)) > 0 % check only for first run
    if b.auto_accept
        response = 'n';
    else
        response = input('Slicetime correction was already run. Do you want to run it again? y/n \n','s');
    end
    if strcmp(response,'y')==1
        disp('Continuing running slicetime correction')
    else
        disp('Skipping slicetime correction')
        runflag = 0;
    end
end

% Run slicetime correction

% First re-organize files into cell array
b.allfiles = {};
for i = 1:length(b.runs)
    b.allfiles{i} = cellstr(b.rundir(i).files); 
end

% run slicetime correction 
if runflag
    % setup batch with slice time paramaters (created in gui on 7_30_17)
    matlabbatch{1}.spm.temporal.st.scans = b.allfiles';
    matlabbatch{1}.spm.temporal.st.nslices = 38;
    matlabbatch{1}.spm.temporal.st.tr = 1220;
    matlabbatch{1}.spm.temporal.st.ta = 0;
    matlabbatch{1}.spm.temporal.st.so = [0 632.49999999 62.5 694.99999999 125 757.49999999 190 819.99999999 252.5 884.99999999 315 947.49999999 377.5 1009.99999999 442.5 1072.49999999 505 1137.5 567.5 0 632.49999999 62.5 694.99999999 125 757.49999999 190 819.99999999 252.5 884.99999999 315 947.49999999 377.5 1009.99999999 442.5 1072.49999999 505 1137.5 567.5];
    matlabbatch{1}.spm.temporal.st.refslice = 0;
    matlabbatch{1}.spm.temporal.st.prefix = 'slicetime_';
    
    spm('defaults','fmri');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end


for i = 1:length(b.runs)
    b.rundir(i).sfiles = spm_select('ExtFPListRec', b.dataDir, ['^slicetime.*'  b.runs{i} '.*bold\.nii']);
    fprintf('%02d:   %0.0f slicetime files found.\n', i, length(b.rundir(i).sfiles))
end

end % end function