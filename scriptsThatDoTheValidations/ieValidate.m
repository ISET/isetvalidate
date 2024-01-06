function ieValidate(repo,typeToRun,varargin)
% Run all tutorials/scripts/validations for a repo and print out which worked and which did not
%
% NOTES:
%
% * BW/ZL made various fixes for isetcam, iset3d.  But they are
% not yet tested.
%
% * Also, there was a bug about finding the right subdirectory.  We
% might have broken the path for isetbio?  But there does not appear
% to be a 'validation' subdirectory anywhere.
%
% Syntax:
%    ieValidate(repo,typeToRun)
%    e.g., ieValidate('isetcam','validations');
%
% Description:
%   Run all of the tutorials/scripts/validations for a specified repo
%   and print out a report at the end as to whether they threw errors,
%   or not.
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
%   12/15/23  dhb  Integrate tutorials/scripts/validations.
%   12/20/23  dhb  Generalized setup to handle bugs identified by BAW.

p = inputParser;
p.addRequired('repo',@(x)(ismember(ieParamFormat(x),{'isetcam','isetbio','csfgenerator','iset3d','psych221'})));
p.addRequired('typeToRun',@(x)(ismember(ieParamFormat(x),{'tutorials','scripts','validations'})));
p.parse(repo,typeToRun,varargin{:});

% Specify repos we can test.  For each, also need to provide
% the name of the function that gives the repository root path
% and the path to the tutorial directory under that path.
%
% I took a guess at the correct root path for iset3d and psych221
availRepos = {'isetbio' 'isetcam', 'csfgenerator','iset3d','psych221','ptb'};
repoRootDirFcns = {'isetbioRootPath' 'isetRootPath', 'csfGeneratorRootPath','piRootPath','psych221RootPath',''};

% Figure out where we want to go today
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

% Choose the top level directory corresponding to the type of
% validation.  For repo and validation type, we specify the
% top level directory of the scripts to run, and the subdirectory
% of that top level directory where the scripts are.
switch (availRepos{selectedRepoNum})
    case 'isetcam'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
            case 'validations'
                topLevelDir = fullfile(isetvalidateRootPath);
                subDir = 'isetcam';
        end

    case 'isetbio'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'isetbio';
        end

    case 'csfgenerator'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
                error('No scripts currently exist for csfgenerator');
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'csfgenerator';
                error('No validations currently exist for csfgenerator');
        end

    case 'iset3d'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
                error('Not sure whether tutorials currently exist for iset3d');
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
                error('Not sure whether currently exist for iset3d');
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'iset3d';
        end

    case 'psych221'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
                error('Not sure whether tutorials currently exist for psych221');
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
                error('Not sure whether scripts currently exist for psych221');
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'psych221';
        end

    case 'ptb'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
                error('Tutorials do not currently exist for ptb');
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
                error('Scripts do not currently exist for ptb');
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'ptb';
        end

    otherwise
        error('We do not know how to handle specified repo');
end

% Set up preferences to work for the selected run
p = struct(...
    'tutorialsSourceDir',       fullfile(topLevelDir,subDir) ...
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
    'v_ISET', ...
    'v_isetcam', ...
    ['hyperspectral' pathsep 'support'] ...
    };

%% Use UnitTestToolbox method to do this.

% Do not show all those little progress bars.  It slows things down.
wbarFlag = ieSessionGet('wait bar');
ieSessionSet('wait bar',0);

% Clear the variables when running the ieValidate.  Otherwise we accumulate
% tons of unwanted variables. It would also be possible to place this
% ieInit inside of the UnitTest.runXXX command, rather than expect it to be
% in each tutorial/script/validation (BW).
initClear = ieSessionGet('init clear');
ieSessionSet('init clear',true);

UnitTest.runProjectTutorials(p, scriptsToSkip, 'All');

% Restore
ieSessionSet('init clear',initClear);
ieSessionSet('wait bar',wbarFlag);
end