% ieValidateEverything
%
% Run all our validation and regression scripts, and save output of each to
% a file.

%% Examples
ieExamples('isetcam');
ieExamples('isetbio');
ieExamples('csfgenerator');

%% Validations
ieValidate(isetcam','scripts');
ieValidate(isetcam,'tutorials');
ieValidate(isetcam,'validations');