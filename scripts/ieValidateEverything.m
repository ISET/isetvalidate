% ieValidateEverything
%
% Run many of our validation and regression test scripts, and save output of each to
% a file.

%% Clear and close
close all hidden; clear all;

%% Validations
ieValidate('isetcam','scripts'); close all; close all hidden; clear all;
ieValidate('isetcam','tutorials'); close all; close all hidden; clear all;
ieValidate('isetcam','validations'); close all hidden; clear all;

ieValidate('isetbio','scripts'); close all; close all hidden; clear all;
ieValidate('isetbio','tutorials'); close all; close all hidden; clear all;
ieValidate('isetbio','validations'); close all; close all hidden; clear all;

ieValidate('csfgenerator','tutorials'); close all; close all hidden; clear 

%% Examples
ieExamples('isetcam'); close all; close all hidden; clear all;
ieExamples('isetbio'); close all; close all hidden; clear all;
ieExamples('csfgenerator'); close all; close all hidden; clear all;

% Old RDT validations.  Great regression checks.
ieValidateRDTFullAll; close all; close all hidden; clear all;
