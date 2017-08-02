function [b] = slice_time_correct(b)
% slice time correct for Rang lab multiband sequence 
% written by Walter Reilly to pre proc the dirty data 
%   Usage:
%
%	b = convert_dicom(b)
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




















































end % end function