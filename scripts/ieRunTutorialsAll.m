function ieRunTutorialsAll
%ieRunTutorialsAll
%
% Syntax
%    ieRunTutorialsAll
%
% Description
%   Run all of the isetcam tutorials and print out a report at the end as
%   to whether they threw errors, or not. Scripts inside of
%   isetRootPath/tutorials are run, except that scripts within the
%   directory 'development' are skipped.
%
%
% 07/26/17  dhb  Wrote this, because we care.
% 07/25/23  dhb  Updated to work in isetbiovalidation repo context

% Specify repos we can test.  For each, also need to provide
% the name of the function that gives the repository root path
% and the path to the tutorial directory under that path.
availRepos = {'isetbio' 'isetcam'};
repoRootDirFcns = {'isetbioRootPath' 'isetRootPath'};
repoTutorialDirs = {'tutorials' 'tutorials'};

% Ask user where we want to go today
fprintf('Available repositories to test\n')
for rr = 1:length(availRepos)
    fprintf('\t%s [%d]\n',availRepos{rr},rr);
end
fprintf('Enter repository to test: ');
commandwindow;
selectedRepoNum = input(sprintf('Enter repository number to test [%d-%d]: ', 1, length(availRepos)));
if (isempty(selectedRepoNum)) || (~isnumeric(selectedRepoNum))
    error('Repository selection  must be an integer');
elseif (selectedRepoNum <= 0) || (selectedRepoNum > length(availRepos))
    error('Repository selection must be in range [%d .. %d]', 1, length(availRepos));
else
    repoToTest = availRepos{selectedRepoNum};
end

% Set up preferences to work for the selected repository
p = struct(...
    'tutorialsSourceDir',       fullfile(eval(repoRootDirFcns{selectedRepoNum}), repoTutorialDirs{selectedRepoNum}) ...
    );

%% List of scripts to be skipped from automatic publishing.
%
% Anything with this in its path name is skipped.
scriptsToSkip = {...
    'development' ...
    'ieRunTutorialsAll', ...
    'ieRunValidateAll', ...
    'ieRunScriptsAll'
    };

%% Use UnitTestToolbox method to do this.
UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');
end