% ieValidateEverything
%
% Run many of our validation and regression test scripts, and save output of each to
% a file.

%% Examples
ieExamples('isetcam'); close all; clear;
ieExamples('isetbio'); close all; clear;
ieExamples('csfgenerator'); close all; clear;

%% Validations
ieValidate('isetcam','scripts'); close all; clear;
ieValidate('isetcam','tutorials'); close all; clear;
ieValidate('isetcam','validations'); close all; clear;

ieValidate('isetbio','scripts'); close all; clear;
ieValidate('isetbio','tutorials'); close all; clear;
ieValidate('isetbio','validations'); close all; clear;

ieValidate('csfgenerator','tutorials'); close all; clear;

ieValidateRDTFullAll; close all; clear;