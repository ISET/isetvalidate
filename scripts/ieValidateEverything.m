% ieValidateEverything
%
% Runmany ofl our validation and regression scripts, and save output of each to
% a file.

%% Examples
ieExamples('isetcam');
ieExamples('isetbio');
ieExamples('csfgenerator');

%% Validations
ieValidate('isetcam','scripts');
ieValidate('isetcam,'tutorials');
ieValidate('isetcam','validations');

ieValidate('isetbio','scripts');
ieValidate('isetbio','tutorials');
ieValidate('isetbio','validations');

ieValidate('csfgenerator','scripts');
ieValidate('csfgenerator','tutorials');
ieValidate('csfgenerator','validations');