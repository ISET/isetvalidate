function rootPath=isetValidatePath()
% Return the path to the root iset validate directory
%
% This function must reside in the directory at the base of the
% ISETCAM validate directory structure.  It is used to determine the
% location of various sub-directories.
%
% Example:
%   fullfile(isetValidatePath,'data')

rootPath=which('isetValidatePath');

rootPath = fileparts(rootPath);

end
