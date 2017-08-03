function [b] = set_origin(b)

%This should really be for all subjects at once, oh well
% Written by Walter Reilly

% inputs b.mprage

% initiate
matlabbatch{1}.spm.util.disp.data = cellstr(b.mprage);

% run 
spm('defaults','fmri');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

fprintf('Set origin to AC!')
keyboard
    
end
