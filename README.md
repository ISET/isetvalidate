# isetvalidate
In July 2023, we started to (a) remove the validation code and data from individual repositories, and (b) merge them into this repository [SETvalidate](https://github.com/ISET/isetvalidate).

The advantages of this approach are

  * individual repositories are simpler
  * changes to validation scripts, do not require a git push/pull in the main repo
  * we can improve the basic features of the validation scripts and apply them across multiple repos

The disadvantage is that people who want to create or use validations need to download this additional repo and include it on their path, as well as obtain a separate repo with the validation data.
And you need the repository [UnitTestToolbox](https://github.com/UnitTestToolbox.git) on your path. We have noticed, however, that most people do not work on validations.

The validations for different repositories are run through the gateway method, ieValidate().  This function can test the validations, scripts, tutorials, and examples in an ISET style repository.  For example,

*  ieValidate('isetcam','validations')
*  ieValidate('isetbio','scripts')
*  ieValidate('isetcam','examples')
*  ieValidate('iset3d','validations')


# History

The original validation data is available at the repository https://github.com/isetbio/isetvalidatedata.git.  You need to clone this to somewhere on your computer to run the validations against the historical data.  DHB and BW extensively tested the new ISETBio/ISETCam organization, using validation scripts, as we refactored the code into cleaners ISETBio and ISETCam repositories.  We do not think others will need these data or to perform these tests.

Some of us have downloaded the original ISETBio validation data and can validate isetbiordt.


## Ancient History (will be deprecated)

ISETBIOORIG -  Copy of the validation scripts from the master branch prior to the ISETBio/ISETCam integration. These were only slightly modified by DHB to simplify the validation.  For example, we no longer check every element of every structure because we know those have changed.  So we validate the numerical data (key properties).  If the photons match at the end, we are good. These are mostly serving as a reference, as the master branch of ISETBio still includes them and when validating on that branch the ones within the branch are the ones to move. We will transition to these versions soon enough.

To run all the validations, use ieValidateFullAll.  To run just one, use ieValidateFullOne. The validations all currently pass on the master branch of ISETBio.

When running on the master branch of ISETBio, to set up for the validations, you need point ISETBio at the validation data. Below is the setup code you need to do so. It sets up a Matlab preference that is checked by the validation scripts.  These scripts are all named v_XXXX.m.  The script name is used to find the right set of validation data.

ISETBIO - These are for the ISETBio/ISETCam configuration. The validation scripts have been renamed to v_ibio_XXX, and read validation data with those script names.  To run these, you need the dev branch of ISETCam, the isetcam branch of ISETBio, and the isetvalidate repository (this repository).

The setup code below is smart enough to detect which of these two configurations you are running and set up appropriately for each.  It will get screwed up if you run on the master branch of isetbio with isetvalidate on your path, however.

Here too, to run all the validations, use ieValidateFullAll.  To run just one, use ieValidateFullOne. The validations all currently pass on the master branch of ISETBio.

We are currently trying to get all validations to pass in the ISETBio/ISETCam configuration.  The document zzISETBio-Cam_Validations_Status.docx describes the current status of those efforts.  Once we get these working, we will rationalize the validation structure further.

The ToolboxToolbox configuration tbUse('isetbio-no-validate') will set you up to run things correctly if you are on the master branch of ISETBio.  The configuration tbUse('isetbio-cam') will set you up to run things correctly if you are on the dev branch of ISETCam and the isetcam branch of ISETBio. ToolboxToolbox is not good at switching branches for you, so you need to do that before running the TbUse command.

Here is the setup code for the validations.  If you use ToolboxToolbox, put this code in your local hook file and it is executed for you automatically.

% Set up the validation root dir differently depending on whether you have the master branch of ISETBio, in which case you should not have this respository on your path,
% or whether you are using this repository.
if (exist('isetvalidateRootPath','file'))
    validationRootDir = fullfile(isetvalidateRootPath, 'isetbio');
else
    validationRootDir = fullfile(isetbioRootPath, 'validation');
end

% Set up a structure with field 'alternateFullDataDir' pointing at the appropriate subdirectory
% of the repo isetvalidatedata.  If you put that data in a projects subdirectory of Matlab's 
% userpath, the code below will do the right thing unmodified.
p = struct(...
    'projectName', 'isetbio', ...
    'validationRootDir', validationRootDir, ...
    'alternateFastDataDir', '', ...
    'alternateFullDataDir', fullfile(userpath, 'projects/isetvalidatedata/gradleFiles/validationFull'), ...
    'useRemoteDataToolbox', ~true, ...
    'remoteDataToolboxConfig', 'isetbio', ...
    'githubRepoURL', 'http://isetbio.github.io/isetbio', ...
    'generateGroundTruthDataIfNotFound', true, ...
    'listingScript', 'ieValidateListAllValidationDirs', ...
    'coreListingScript', 'ieValidateListCoreValidationFiles', ...
    'numericTolerance', 1e-11);

% Add to the path the validation directory location
addpath(genpath(p.alternateFullDataDir));

% Set up the preferences we need and tell the UnitTestToolbox
% what they are.  The function generatePreferenceGroup is just below.
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
