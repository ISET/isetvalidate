function ieRunValidationsAll(repo)
%ieRunTutorialsAll
%
% Description:
%   Run validations and print out a report at the end.  Implemented
%   originally for ISETBio, and then extended to other repositories
%   through the isetvalidate repository method.
%
%   Requires the Unit test repository on your path.

if notDefined('repo'), repo = 'isetcam'; end

switch ieParamFormat(repo)
    case 'isetcam'
        p = struct(...
            'rootDirectory',           isetValidatePath, ...
            'tutorialsSourceDir',      fullfile(isetValidatePath, 'isetcam') ...
            );

        scriptsToSkip = {...
            'v_ISET' ...
            'v_manualViewer',...
            'data'  ...          
            };

        fprintf('*** We suggest running v_manualViewer from time to time.***\n');

    case 'isetbio'
        % User/project specific preferences
        p = struct(...
            'rootDirectory',            fileparts(which(mfilename())), ...
            'tutorialsSourceDir',       fullfile(isetValidatePath, 'isetbio') ...
            );

        % Anything with this in its path name is skipped.
        scriptsToSkip = {...
            'codedevscripts', ...
            'xNeedChecking', ...
            'rgc' ...
            };
    otherwise
        error('Unknown repo %s\n',repo);
end

%% Use UnitTestToolbox method to do this.
UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');

end