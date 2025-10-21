function report = ieValidate(repo,typeToRun,varargin)
% Run all tutorials/scripts/validations for a repo and print out which worked and which did not
%
% Syntax:
%    report = ieValidate(repo,typeToRun)
%
% Description:
%   Run all of the tutorials/scripts/validations for a specified repo
%   and print out a report at the end as to whether they threw errors,
%   or not.  The report is also returned
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
%   repo - name of repository. 
%       One of {'isetcam','isetbio','isetbiordt','csfgenerator', 'iset3d', 'iset3d-tiny', 'psych221'}
%   typeToRun - One of {'tutorials', 'scripts', 'validations'}
%       Not all combinations of repo/typeToRun are available.  The
%       examples block in the source for this routine indicates those
%       that are likely to.
%
%   Before running isetbiordt, you need to install the critical data.
%   See below.
%
% Outputs
%  report
%
%  ISETBIORDT - For historical testing, we have a script and method to
%   install the old ISETBio RDT data locally. (validateRDTSetup).  We use
%   this to put the old data in iesetvalidate/local/ISETBioValidationFiles.
%   Then we run ieValidateRDTFullAll.
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
    ieValidate('csfgenerator','tutorials');
    
    ieValidate('isetcam','scripts');

    ieValidate('isetcam','validations');
    ieValidate('isetbio','validations');
    ieValidate('iset3d','validations');
    ieValidate('iset3d-tiny','validations');
    ieValidate('psych221','validations');

    ieValidate('isetbiordt','validations');

    ieValidate('isetcam','examples');

%}

% History:
%   07/26/17  dhb  Wrote this, because we care.
%   07/25/23  dhb  Updated to work in isetbiovalidation repo context
%   12/15/23  dhb, fh  Add ISETBioCSFGenerator to options
%   12/15/23  dhb  Integrate tutorials/scripts/validations.
%   12/20/23  dhb  Generalized setup to handle bugs identified by BAW.

%% Specify repos we can test.  
% 
% For each, also need to provide the name of the function that gives the
% repository root path and the path to the tutorial directory under that
% path.

availRepos = {'isetbio' 'isetcam', 'csfgenerator','iset3d','iset3d-tiny'...
    'psych221','ptb','isetbiordt','isetfundamentals'};
repoRootDirFcns = {'isetbioRootPath' 'isetRootPath', ...
    'csfGeneratorRootPath','piRootPath','piRootPath','psych221RootPath',...
    'iefundamentalsRootPath'};
%%

% Specify repos we can test.  For each, also need to provide
% the name of the function that gives the repository root path
% and the path to the tutorial directory under that path.
%
% I took a guess at the correct root path for iset3d and psych221
availRepos = {'isetbio' 'isetcam', 'csfgenerator','iset3d','iset3d-tiny','psych221','ptb','isetbiordt','isetfundamentals'};
repoRootDirFcns = {'isetbioRootPath' 'isetRootPath', 'csfGeneratorRootPath','piRootPath','piRootPath','psych221RootPath','',[],[]};

p = inputParser;
p.addRequired('repo',@(x)(ismember(ieParamFormat(x),availRepos)));
p.addRequired('typeToRun',@(x)(ismember(ieParamFormat(x),{'tutorials','scripts','validations','examples'})));
p.addParameter('saveprint',true,@islogical);
p.parse(repo,typeToRun,varargin{:});

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
                outputFileBase = 'isetcam_tutorials';
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
                outputFileBase = 'isetcam_scripts';
            case 'validations'
                topLevelDir = fullfile(isetvalidateRootPath);
                subDir = 'isetcam';
                outputFileBase = 'isetcam_validations';
            case 'examples'
                ieExamples('isetcam');
                return;
        end

    case 'isetbio'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
                outputFileBase = 'isetbio_tutorials';                 
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
                outputFileBase = 'isetbio_scripts';
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'isetbio';
                outputFileBase = 'isetbio_validations';
            case 'examples'
                ieExamples('isetbio');
                return;
        end

    case 'csfgenerator'
        switch (typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
                outputFileBase = 'csfgenerator_tutorials';
            case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
                outputFileBase = 'csfgenerator_scripts';
                error('No scripts currently exist for csfgenerator');
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'csfgenerator';
                outputFileBase = 'csfgenerator_validations';
                error('No validations currently exist for csfgenerator');
        end

        % case 'iset3d'
        %     switch (typeToRun)
        %         case 'tutorials'
        %             topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
        %             subDir = 'tutorials';
        %             error('Not sure whether tutorials currently exist for iset3d');
        %         case 'scripts'
        %             topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
        %             subDir = 'scripts';
        %             error('Not sure whether currently exist for iset3d');
        %         case 'validations'
        %             topLevelDir = isetvalidateRootPath;
        %             subDir = 'iset3d';
        %     end

    case 'iset3d'
        % We need to make sure iset3d-tiny is renamed to iset3d.
       switch(typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                outputFileBase = 'iset3d_tutorials';
                subDir = 'tutorials';
           case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                outputFileBase = 'iset3d_scripts';
                subDir = 'scripts';           
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                outputFileBase = 'iset3d_validations';
                subDir = 'iset3d';
       end
    
    case 'iset3d-tiny'
        % We need to make sure iset3d-tiny is renamed to iset3d.
       switch(typeToRun)
            case 'tutorials'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                outputFileBase = 'iset3d-tiny_tutorials';
                subDir = 'tutorials';
           case 'scripts'
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                outputFileBase = 'iset3d-tiny_scripts';
                subDir = 'scripts';           
            case 'validations'
                outputFileBase = 'iset3d-tiny_validations';
                topLevelDir = isetvalidateRootPath;
                subDir = 'iset3d';
       end

    case 'psych221'
        % There is a validation script inside of psych221.  Run that.
        switch (typeToRun)
            case 'tutorials'
                error('Not sure whether tutorials currently exist for psych221');
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'tutorials';
            case 'scripts'
                error('Not sure whether scripts currently exist for psych221');
                topLevelDir = eval(repoRootDirFcns{selectedRepoNum});
                subDir = 'scripts';
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                outputFileBase = 'psych221_validations';
                subDir = 'psych221';
            case 'examples'
                ieExamples('psych221');
                return;
        end

    case 'isetfundamentals'
        switch typeToRun
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                outputFileBase = 'isetfundamentals_validations';
                subDir = 'isetfundamentals';
            otherwise
                warning('Only validations are implemented for isetfundamentals now.')
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
                topLevelDir = fullfile(isetvalidateRootPath);
                outputFileBase = 'ptb_validations';
                subDir = 'ptb';
                error('PTB validations need some thinking about how to get PTB onto path for testing here.');
        end

    case 'isetbiordt'
        % This is an external call to ieValidateRDTFullAll.  The user has
        % to have the RDT data set up in the path.  These files are
        % installed using the script validateRDTSetup, by setting the
        % variable
        %
        %    whereIPutTheUnzippedFile
        %
        % I think by default they should be in the directory
        %
        %    isetvalidate/local/ISETBioValidationFiles 
        %
        switch typeToRun
            case 'validations'
                if ~exist(fullfile(isetvalidateRootPath,'local','ISETBioValidationFiles'),'dir')
                    warning('Validation files not in expected location.  Trying anyway.');
                end
                ieValidateRDTFullAll;
                return;
            otherwise
                error('For ISETBIORDT we only run validations.')
        end

    otherwise
        error('We do not know how to handle specified repo');
end

% Set up preferences to work for the selected run
pp = struct(...
    'tutorialsSourceDir',       fullfile(topLevelDir,subDir) ...
    );

%% List of scripts to be skipped from automatic running.
%
% Anything with one of these strings in the path name is skipped.
scriptsToSkip = {...
    'Contents', ...
    'data', ...
    'deprecated', ...
    'development', ...
    'Development', ...
    'ieRunTutorialsAll', ...
    'ieRunValidateAll', ...
    'ieRunScriptsAll', ...
    'xNotOnPath', ...
    'v_ISET', ...
    'v_isetcam', ...
    'v_iset3d_main', ...
    'v_iset3d_tiny_main', ...
    'library', ...
    ['scripts' filesep 'image' filesep 'jpegFiles'], ...
    ['scripts' filesep 'optics' filesep 'chromAb'], ...
    ['hyperspectral' filesep 'support'] ...
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

[~, reportTemp] = UnitTest.runProjectTutorials(pp, scriptsToSkip, 'All');

% Restore
ieSessionSet('init clear',initClear);
ieSessionSet('wait bar',wbarFlag);

% This has the effect that if you call the function from the command
% line and don't assign its output to anything and don't put in a
% semi-colon, you don't get the report string dumped out.  The reason we
% want this is that the report string is already printed out with the
% broken ones in color, and if we print it out again that version rolls off
% the screen.
if (nargout > 0)
    report = reportTemp;
end

% Save what happend to a file
if (p.Results.saveprint)
    % Make sure save directory exists and set up save filenme, if saving
    outputDir = fullfile(isetvalidateRootPath,'outputfiles',datestr(now,'yyyy-mm-dd'));
    if (~exist(outputDir,'dir'))
        mkdir(outputDir);
    end
    outputFile = fullfile(outputDir,[outputFileBase '_' datestr(now,'yyyy-mm-dd-HH-MM-SS')]);
    outputFID = fopen(outputFile,'w');
    fprintf(outputFID,reportTemp);
    fclose(outputFID);
end

end