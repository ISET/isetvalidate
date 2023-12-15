function ieValidate(repo,typeToRun,varargin)
% Run all tutorials/scripts/validations for a repo and print out which worked and which did not
%
% Syntax:
%    ieValidate(repo,typeToRun)
%
% Description:
%   Run all of the tutorials/scripts/validations for a specified repo and print out a report at the end as
%   to whether they threw errors, or not.
% 
%   The path to the tutorials is setup in the source of this routine, as
%   are various strings that will cause something to be skipped if it is in
%   the pathname (e.g., paths with 'development' are skipped).
%
%   Particular tutorials/scripts/validations will also be skipped if they
%   contain a comment line of the form
%       % UTTBSkip
%   in their source file.
%
% Inputs:
%   repo - name of repository. One of {'isetcam','isetbio','csfgenerator', 'iset3d', 'psych221'}
%   typeToRun - One of {'tutorials', 'scripts', 'validations'}
%
%   Not all combinations of repo/typeToRun are available.  The examples
%   block in the source for this routine indicates those that are likely
%   to.
%
% Outputs:
%   None.
%
% Optional key/value pairs
%   None.

% Examples:
%{
   % ETTBSkip
   % 
   % You need to make sure you have the underlying repos on your path
   % these will work.

    ieValidate('isetcam','tutorials');
    ieValidate('isetbio','tutorials');
    ieValidate('csfgenerator,'tutorials');

    ieValidate('isetcam','scripts');

    ieValidate('isetcam','validations');
    ieValidate('isetbio','validations');
    ieValidate('iset3d','validations');
    ieValidate('psych221','validations');
%}

% History:
%   07/26/17  dhb  Wrote this, because we care.
%   07/25/23  dhb  Updated to work in isetbiovalidation repo context
%   12/15/23  dhb, fh  Add ISETBioCSFGenerator to options
%   12/15/21  dhb  Integrate tutorials/scripts/validations.

p = inputParser;
p.addRequired('repo',@(x)(ismember(ieParamFormat(x),{'isetcam','isetbio','csfgenerator','iset3d','psych221'})));
p.addRequired('typeToRun',@(x)(ismember(ieParamFormat(x),{'tutorials','scripts','validations'})));
p.parse(repo,typeToRun,varargin{:});

% Specify repos we can test.  For each, also need to provide
% the name of the function that gives the repository root path
% and the path to the tutorial directory under that path.
%
% I took a guess at the correct root path for iset3d and psych221
availRepos = {'isetbio' 'isetcam', 'csfgenerator','iset3d','psych221'};
repoRootDirFcns = {'isetbioRootPath' 'isetRootPath', 'csfGeneratorRootPath','iset3dRootPath','psych221RootPath'};

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

% Set up variables to handle what was specified
switch (availRepos{selectedRepoNum})
    case 'isetcam'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
            case 'validations'
                topLevelDir = eval(isetvalidateRootPath);
        end

    case 'isetbio'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
            case 'validations'
                topLevelDir = eval(isetvalidateRootPath);
        end

    case 'csfgenerator'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
            case 'scripts'
                error('No scripts currently exist for csfgenerator');
            case 'validations'
                error('No validations currently exist for csfgenerator');
        end

    case 'iset3d'
        case 'tutorials'
                error('Not sure whether tutorials currently exist for iset3d');
            case 'scripts'
                error('Not sure whether currently exist for iset3d');
            case 'validations'
                topLevelDir = eval(isetvalidateRootPath);
    
    case 'psych221'
        case 'tutorials'
                error('Not sure whether tutorials currently exist for psych221');
            case 'scripts'
                error('Not sure whether tutorials urrently exist for psych221');
            case 'validations'
                topLevelDir = eval(isetvalidateRootPath);

    otherwise
        error('We do not know how to handle specified repo');
end

% Set up preferences to work for the selected repository
p = struct(...
    'tutorialsSourceDir',       fullfile(topLevelDir, typeToRun) ...
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