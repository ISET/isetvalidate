function validateRDTSetup
% Stripped down version of ISETBio local hook to allow someone to setup the
% RDT validations.

% Edit this to point at where you put your validation data file
whereIPutTheUnzippedFile = fullfile(isetvalidateRootPath,'local','ISETBioValidationFiles');
fprintf('Assuming validation data files are in %s',whereIPutTheUnzippedFile);

% whereIPutTheUnzippedFile = '/Users/dhb/Desktop/ISETBioValidationFiles';

% Point at the validation data and other setup.  You should not have to
% edit this.
validationRootDir = fullfile(isetvalidateRootPath, 'isetbioRDT');
listingScript = 'ieValidateRDTListAllValidationDirs';
validationFilesAreHere = fullfile(whereIPutTheUnzippedFile,'gradleFiles','validationFull');

% Populate the struct we need.  You should not have to edit this.
p = struct(...
    'projectName', 'isetbio', ...
    'validationRootDir', validationRootDir, ...
    'alternateFastDataDir', '', ...
    'alternateFullDataDir', validationFilesAreHere, ...
    'useRemoteDataToolbox', ~true, ...
    'remoteDataToolboxConfig', 'isetbio', ...
    'githubRepoURL', 'http://isetbio.github.io/isetbio', ...
    'rgcResources', '', ...
    'generateGroundTruthDataIfNotFound', true, ...
    'listingScript', listingScript, ...
    'coreListingScript', '', ...
    'numericTolerance', 1e-11);

% Add validation data to the pass tos that a load will find it.
addpath(genpath(p.alternateFullDataDir));

% Set up UnitTestToolbox preferences
generatePreferenceGroup(p);
UnitTest.usePreferencesForProject(p.projectName);

end

function generatePreferenceGroup(p)
% Remove any existing preferences for this project
%
% Syntax:
%   generatePreferenceGroup(p)
%
% Description:
%    Remove existing preferences for the provided project p.
%
% Inputs:
%    p - Object. A project object.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

if ispref(p.projectName), rmpref(p.projectName); end

% generate and save the project-specific preferences
setpref(p.projectName, 'projectSpecificPreferences', p);
fprintf('Generated and saved preferences specific to the %s project.\n', p.projectName);
end
