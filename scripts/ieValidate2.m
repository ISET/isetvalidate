function [report, filesToTest] = ieValidate2(repo, typeToRun, varargin)
% Run all tutorials/scripts/validations for a repo and print out which worked and which did not.
%
% Syntax:
%   report = ieValidate2(repo, typeToRun)
%   [report, filesToTest] = ieValidate2(repo, typeToRun, 'listonly', true)
%
% Description:
%   This function is a safer refactor of ieValidate. It keeps the same
%   behavior for execution, and it adds list-only mode. In 'list only'
%   mode, files are discovered and filtered, but not executed.
%
% Inputs:
%   repo - repository name.
%     One of {'isetcam','isetbio','isetbiordt','csfgenerator', ...
%             'iset3d','iset3d-tiny','psych221','ptb','isetfundamentals'}
%   typeToRun - One of {'tutorials','scripts','validations','examples'}
%
% Optional key/value pairs:
%   'save print' - logical, default true.
%     Save execution report to isetvalidate/outputfiles/<date>.
%   'list only' - logical, default false.
%     If true, return the list of files that would be tested, do not run.
%
% Outputs:
%   report - execution summary string, or list summary in list-only mode.
%   filesToTest - cell array of full paths selected for testing.
%
% Examples:
%{
%   ieValidate2('isetcam','tutorials');
%   [~, files] = ieValidate2('isetbio','scripts','listonly',true);
%}

varargin = ieParamFormat(varargin);

availRepos = {'isetbio', 'isetcam', 'csfgenerator', 'iset3d', 'iset3d-tiny', ...
    'psych221', 'ptb', 'isetbiordt', 'isetfundamentals'};
availTypes = {'tutorials', 'scripts', 'validations', 'examples'};

p = inputParser;
p.addRequired('repo', @(x)(ismember(ieParamFormat(x), availRepos)));
p.addRequired('typeToRun', @(x)(ismember(ieParamFormat(x), availTypes)));
p.addParameter('saveprint', true, @islogical);
p.addParameter('listonly', false, @islogical);
p.parse(repo, typeToRun, varargin{:});

% Normalize once to avoid mismatches later in dispatch.
repo = ieParamFormat(repo);
typeToRun = ieParamFormat(typeToRun);

if strcmp(typeToRun, 'examples')
    switch repo
        case {'isetcam', 'isetbio', 'psych221'}
            ieExamples(repo);
            report = '';
            filesToTest = {};
            return;
        otherwise
            error('Examples are not implemented for repo ''%s''.', repo);
    end
end

[topLevelDir, subDir, outputFileBase, isExternalRun] = localResolveRunConfig(repo, typeToRun);

% Paths and skip patterns for UnitTestToolbox.
pp = struct('tutorialsSourceDir', fullfile(topLevelDir, subDir));
scriptsToSkip = { ...
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

% External validation path (isetbiordt) executes outside UnitTest flow.
if isExternalRun
    if p.Results.listonly
        filesToTest = {};
        report = sprintf('List-only mode is not implemented for repo ''%s'' and type ''%s'' (external runner).\n', repo, typeToRun);
        fprintf('%s', report);
        return;
    end

    ieValidateRDTFullAll;
    report = '';
    filesToTest = {};
    return;
end

% Build the runnable list using UnitTest-style skip logic.
[filesToTest, skippedFiles] = localDiscoverFilesToTest(pp.tutorialsSourceDir, scriptsToSkip);

if p.Results.listonly
    report = localBuildListOnlyReport(pp.tutorialsSourceDir, filesToTest, skippedFiles);
    fprintf('%s', report);
    return;
end

% Preserve and always restore session prefs, even when execution throws.
wbarFlag = ieSessionGet('wait bar');
initClear = ieSessionGet('init clear');
ieSessionSet('wait bar', 0);
ieSessionSet('init clear', true);
cleanupObj = onCleanup(@() localRestoreSessionFlags(wbarFlag, initClear)); %#ok<NASGU>

[~, reportTemp] = UnitTest.runProjectTutorials(pp, scriptsToSkip, 'All');

if nargout > 0
    report = reportTemp;
else
    report = '';
end

if p.Results.saveprint
    outputDir = fullfile(isetvalidateRootPath, 'outputfiles', datestr(now, 'yyyy-mm-dd'));
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    outputFile = fullfile(outputDir, [outputFileBase '_' datestr(now, 'yyyy-mm-dd-HH-MM-SS')]);
    outputFID = fopen(outputFile, 'w');
    if outputFID == -1
        error('ieValidate2:FileOpenFailed', 'Could not open output file for writing: %s', outputFile);
    end
    fileCleanup = onCleanup(@() fclose(outputFID)); %#ok<NASGU>
    fprintf(outputFID, '%s', reportTemp);
end

end


function [topLevelDir, subDir, outputFileBase, isExternalRun] = localResolveRunConfig(repo, typeToRun)
isExternalRun = false;

switch repo
    case 'isetcam'
        switch typeToRun
            case 'tutorials'
                topLevelDir = isetRootPath;
                subDir = 'tutorials';
                outputFileBase = 'isetcam_tutorials';
            case 'scripts'
                topLevelDir = isetRootPath;
                subDir = 'scripts';
                outputFileBase = 'isetcam_scripts';
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'isetcam';
                outputFileBase = 'isetcam_validations';
        end

    case 'isetbio'
        switch typeToRun
            case 'tutorials'
                topLevelDir = isetbioRootPath;
                subDir = 'tutorials';
                outputFileBase = 'isetbio_tutorials';
            case 'scripts'
                topLevelDir = isetbioRootPath;
                subDir = 'scripts';
                outputFileBase = 'isetbio_scripts';
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'isetbio';
                outputFileBase = 'isetbio_validations';
        end

    case 'csfgenerator'
        switch typeToRun
            case 'tutorials'
                topLevelDir = csfGeneratorRootPath;
                subDir = 'tutorials';
                outputFileBase = 'csfgenerator_tutorials';
            case 'scripts'
                error('No scripts currently exist for csfgenerator');
            case 'validations'
                error('No validations currently exist for csfgenerator');
        end

    case 'iset3d'
        switch typeToRun
            case 'tutorials'
                topLevelDir = piRootPath;
                subDir = 'tutorials';
                outputFileBase = 'iset3d_tutorials';
            case 'scripts'
                topLevelDir = piRootPath;
                subDir = 'scripts';
                outputFileBase = 'iset3d_scripts';
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'iset3d';
                outputFileBase = 'iset3d_validations';
        end

    case 'iset3d-tiny'
        switch typeToRun
            case 'tutorials'
                topLevelDir = piRootPath;
                subDir = 'tutorials';
                outputFileBase = 'iset3d-tiny_tutorials';
            case 'scripts'
                topLevelDir = piRootPath;
                subDir = 'scripts';
                outputFileBase = 'iset3d-tiny_scripts';
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'iset3d';
                outputFileBase = 'iset3d-tiny_validations';
        end

    case 'psych221'
        switch typeToRun
            case 'tutorials'
                error('Not sure whether tutorials currently exist for psych221');
            case 'scripts'
                error('Not sure whether scripts currently exist for psych221');
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'psych221';
                outputFileBase = 'psych221_validations';
        end

    case 'isetfundamentals'
        switch typeToRun
            case 'validations'
                topLevelDir = isetvalidateRootPath;
                subDir = 'isetfundamentals';
                outputFileBase = 'isetfundamentals_validations';
            otherwise
                error('Only validations are implemented for isetfundamentals.');
        end

    case 'ptb'
        switch typeToRun
            case 'tutorials'
                error('Tutorials do not currently exist for ptb');
            case 'scripts'
                error('Scripts do not currently exist for ptb');
            case 'validations'
                error('PTB validations need path setup before running via this function.');
        end

    case 'isetbiordt'
        switch typeToRun
            case 'validations'
                if ~exist(fullfile(isetvalidateRootPath, 'local', 'ISETBioValidationFiles'), 'dir')
                    warning('Validation files not in expected location. Trying anyway.');
                end
                topLevelDir = '';
                subDir = '';
                outputFileBase = 'isetbiordt_validations';
                isExternalRun = true;
            otherwise
                error('For ISETBIORDT we only run validations.');
        end

    otherwise
        error('Unknown repository requested: %s', repo);
end

if isempty(topLevelDir) || isempty(subDir)
    error('No runnable directory was resolved for repo ''%s'' with type ''%s''.', repo, typeToRun);
end

if ~exist(fullfile(topLevelDir, subDir), 'dir')
    error('Source directory does not exist: %s', fullfile(topLevelDir, subDir));
end
end


function [filesToTest, skippedFiles] = localDiscoverFilesToTest(sourceDir, scriptsToSkip)
allFiles = localGetContents(sourceDir);
filesToTest = {};
skippedFiles = {};

for ii = 1:numel(allFiles)
    thisFile = allFiles{ii};

    if localSkipByPath(thisFile, scriptsToSkip)
        skippedFiles{end+1} = thisFile; %#ok<AGROW>
        continue;
    end

    if localHasUTTBSkip(thisFile)
        skippedFiles{end+1} = thisFile; %#ok<AGROW>
        continue;
    end

    filesToTest{end+1} = thisFile; %#ok<AGROW>
end
end


function yes = localSkipByPath(filePath, scriptsToSkip)
yes = false;
for l = 1:numel(scriptsToSkip)
    if ~isempty(strfind(filePath, scriptsToSkip{l})) %#ok<STREMP>
        yes = true;
        return;
    end
end
end


function yes = localHasUTTBSkip(filePath)
yes = false;
fileID = fopen(filePath, 'r');
if fileID == -1
    warning('ieValidate2:FileOpenFailed', 'Could not open file while scanning for UTTBSkip: %s', filePath);
    return;
end
cleanupObj = onCleanup(@() fclose(fileID)); %#ok<NASGU>
fileText = char(fread(fileID, 'uint8=>char')');
yes = ~isempty(strfind(fileText, '% UTTBSkip')); %#ok<STREMP>
end


function files = localGetContents(directory)
files = {};

mFiles = dir(fullfile(directory, '*.m'));
for k = 1:numel(mFiles)
    files{end+1} = fullfile(directory, mFiles(k).name); %#ok<AGROW>
end

mlxFiles = dir(fullfile(directory, '*.mlx'));
for k = 1:numel(mlxFiles)
    files{end+1} = fullfile(directory, mlxFiles(k).name); %#ok<AGROW>
end

entries = dir(directory);
for k = 1:numel(entries)
    entryName = entries(k).name;
    if entries(k).isdir && ~strcmp(entryName, '.') && ~strcmp(entryName, '..') && ~strcmp(entryName, 'html')
        nestedFiles = localGetContents(fullfile(directory, entryName));
        files = [files nestedFiles]; %#ok<AGROW>
    end
end
end


function report = localBuildListOnlyReport(sourceDir, filesToTest, skippedFiles)
report = sprintf('\n ***** ieValidate2 list-only summary *****\n');
report = [report sprintf('Source dir: %s\n', sourceDir)]; %#ok<AGROW>
report = [report sprintf('Runnable files: %d\n', numel(filesToTest))]; %#ok<AGROW>
report = [report sprintf('Skipped files: %d\n\n', numel(skippedFiles))]; %#ok<AGROW>

for ii = 1:numel(filesToTest)
    report = [report sprintf('%s\n', filesToTest{ii})]; %#ok<AGROW>
end
end


function localRestoreSessionFlags(wbarFlag, initClear)
ieSessionSet('init clear', initClear);
ieSessionSet('wait bar', wbarFlag);
end