function ieValidate(repo,varargin)
% Run the selected validation files in isetvalidate
%
% Synopsis
%    lst = ieValidate(repo,varargin)
%
% Inpput
%   repo - Name of the ISET related repository
%
% Key/val
%   select - 'all' or 'one'
%
% Returns
%   Prints result to cmd.  Should return it as a string before long
%
% Description:
%   Run validations and print out a report at the end.  Implemented
%   originally for ISETBio, and then extended to other repositories
%   through the isetvalidate repository method.
%
% Requires the Unit test repository on your path.
%
% See also
%   ieValidateList
%

%%

if notDefined('repo'), repo = 'isetcam'; end

p = inputParser;
p.addRequired('repo',@(x)(ismember(ieParamFormat(x),{'isetcam','isetbio','iset3d'})));
p.addParameter('select','all',@(x)(ismember(ieParamFormat(x),{'all','one'})));
p.parse(repo,varargin{:});
select = p.Results.select;

switch ieParamFormat(repo)
    case 'isetcam'
        p = struct(...
            'rootDirectory',           isetvalidateRootPath, ...
            'tutorialsSourceDir',      fullfile(isetvalidateRootPath, 'isetcam') ...
            );

        scriptsToSkip = {...
            'development', ...
            'deprecated', ...
            'v_ISET', ...
            'v_isetcam', ...
            'v_manualViewer',...
            'data'  ...          
            };

        fprintf('*** We suggest running v_manualViewer from time to time.***\n');

    case 'isetbio'
        % User/project specific preferences
        p = struct(...
            'rootDirectory',            fileparts(which(mfilename())), ...
            'tutorialsSourceDir',       fullfile(isetvalidateRootPath, 'isetbio') ...
            );

        % Anything with this in its path name is skipped.
        scriptsToSkip = {...
            'development', ...
            'deprecated', ...
            'codedevscripts', ...
            'rgc' ...
            };

    case 'iset3d'
        % User/project specific preferences
        p = struct(...
            'rootDirectory',            fileparts(which(mfilename())), ...
            'tutorialsSourceDir',       fullfile(isetvalidateRootPath, 'iset3d') ...
            );

        %% List of scripts to be skipped
        %
        % Anything with this in its path name is skipped.
        scriptsToSkip = {...
            'v_iset3d_main', ...
            'development', ...
            'deprecated', ...
            };

    otherwise
        error('Unknown repo %s\n',repo);
end

switch select
    case 'all'
        % Use UnitTestToolbox method to do this.
        UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');
    case 'one'
        % Create a list of the files.
    otherwise
        error('Unknown select method %s',select);
end

end