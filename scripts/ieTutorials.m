function ieTutorials(repo,varargin)
% Run all tutorials in repo and print out which worked and which did not
%
% Syntax:
%    ieTutorials(repo)
%
% Description:
%   Run all of the tutorials in a specified repo and print out a report at the end as
%   to whether they threw errors, or not. The path to the tutorials is
%   specified in the source and is currently the 'tutorials' folder in the
%   specified repo, except that scripts within directories whose name
%   contains 'development' are skipped.
%
% Inputs:
%   repo - name of repository ('isetcam','isetbio')
%
% Outputs:
%   None.
%
% Optional key/value pairs
%   None.

% History:
%   07/26/17  dhb  Wrote this, because we care.
%   07/25/23  dhb  Updated to work in isetbiovalidation repo context

p = inputParser;
p.addRequired('repo',@(x)(ismember(ieParamFormat(x),{'isetcam','isetbio'})));
p.parse(repo,varargin{:});

% Specify repos we can test.  For each, also need to provide
% the name of the function that gives the repository root path
% and the path to the tutorial directory under that path.
availRepos = {'isetbio' 'isetcam'};
repoRootDirFcns = {'isetbioRootPath' 'isetRootPath'};
repoTutorialDirs = {'tutorials' 'tutorials'};

% Ask user where we want to go today
knownRepo = false;
for rr = 1:length(availRepos)
    if (strcmp(repo,availRepos{rr}))
        knownRepo = true;
        selectedRepoNum = rr;
        break;
    end
end
if (~knownRepo)
    error('Unknown repository requested')
end

% Set up preferences to work for the selected repository
p = struct(...
    'tutorialsSourceDir',       fullfile(eval(repoRootDirFcns{selectedRepoNum}), repoTutorialDirs{selectedRepoNum}) ...
    );

%% List of scripts to be skipped from automatic running.
%
% Anything with this in its path name is skipped.
scriptsToSkip = {...
    'Contents', ...
    'development', ...
    'Development', ...
    'ieRunTutorialsAll', ...
    'ieRunValidateAll', ...
    'ieRunScriptsAll', ...
    ['hyperspectral' pathsep 'support'] ...
    };

%% Use UnitTestToolbox method to do this.
UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');

end