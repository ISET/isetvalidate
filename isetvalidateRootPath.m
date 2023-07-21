function rootPath=isetvalidateRootPath()
% Return the path to the root isetvalidate directory
%
% This function must reside in the directory at the base of the
% ISETCAM validate directory structure.  It is used to determine the
% location of various sub-directories.
%

rootPath = which('isetvalidateRootPath');

rootPath = fileparts(rootPath);

end
