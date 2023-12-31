% v_isetcam
%
% Runs a subset of the tutorial and validation scripts to check a wide
% variety of functions. 
% 
% We used to run these whenever there are significant changes to ISET
% and prior to checking in the new code. It has not been replaced by
% the ieRunValidateAll function, which runs all of the validation
% scripts automatically.
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Sometimes we have trouble because of a failure to clear variables

% We save the current status, but we clear the variables in this
% session.  Then we reset at the end.
ieSessionSet('init clear',true);

%% Initialize
ieInit;
setpref('ISETValidate', 'benchmarkstart', cputime); % if I just put it in a variable it gets cleared:(
setpref('ISETValidate', 'tStart', tic);

%% Scene tests
disp('*** Scenes')
setpref('ISETValidate', 'tvsceneStart', tic);
v_icam_scene
setpref('ISETValidate', 'tvsceneTime', toc(getpref('ISETValidate', 'tvsceneStart', 0)));
%% Optics tests
disp('*** Optics')
setpref('ISETValidate', 'tvopticsStart', tic);
v_icam_oi
v_icam_diffuser
v_icam_opticsSI
v_icam_opticsWVF
setpref('ISETValidate', 'tvopticsTime', toc(getpref('ISETValidate', 'tvopticsStart')));

%% Sensor tests
disp('*** Sensor')
setpref('ISETValidate', 'tvsensorStart', tic);
v_icam_sensor
setpref('ISETValidate', 'tvsensorTime', toc(getpref('ISETValidate', 'tvsensorStart')));

%% Pixel tests
disp('*** Pixel')
setpref('ISETValidate', 'tvpixelStart', tic);
v_icam_pixel
setpref('ISETValidate', 'tvpixelTime', toc(getpref('ISETValidate', 'tvpixelStart')));

%% Image processing
disp('*** IP');
setpref('ISETValidate', 'tvipStart', tic);
v_icam_imageProcessor
setpref('ISETValidate', 'tvipTime', toc(getpref('ISETValidate', 'tvipStart')));

%% Metrics tests
disp('*** Metrics');
setpref('ISETValidate', 'tvmetricsStart', tic);
v_icam_metrics
setpref('ISETValidate', 'tvmetricsTime', toc(getpref('ISETValidate', 'tvmetricsStart')));

%% Computational Imaging tests
disp('*** CI');
setpref('ISETValidate', 'tvciStart', tic);
setpref('ISETValidate', 'tvciTime', toc(getpref('ISETValidate', 'tvciStart')));

%% Display window
disp('*** Display');
setpref('ISETValidate', 'tvdisplayStart', tic);
t_displayIntroduction;
setpref('ISETValidate', 'tvdisplayTime', toc(getpref('ISETValidate', 'tvdisplayStart')));

%% Summary
tTotal = toc(getpref('ISETValidate','tStart'));
afterTime = cputime;
beforeTime = getpref('ISETValidate', 'benchmarkstart', 0);
glData = opengl('data');
disp(strcat("v_ISET ran  on: ", glData.Vendor, " ", glData.Renderer, "with driver version: ", glData.Version));
disp(strcat("v_ISET ran  in: ", string(afterTime - beforeTime), " seconds of CPU time."));
disp(strcat("v_ISET ran  in: ", string(tTotal), " total seconds."));
fprintf("Scenes  ran in: %5.1f seconds.\n", getpref('ISETValidate','tvsceneTime'));
fprintf("Optics  ran in: %5.1f seconds.\n", getpref('ISETValidate','tvopticsTime'));
fprintf("Sensor  ran in: %5.1f seconds.\n", getpref('ISETValidate','tvsensorTime'));
fprintf("IP      ran in: %5.1f seconds.\n", getpref('ISETValidate','tvipTime'));
fprintf("Display ran in: %5.1f seconds.\n", getpref('ISETValidate','tvdisplayTime'));
fprintf("Metrics ran in: %5.1f seconds.\n", getpref('ISETValidate','tvmetricsTime'));
fprintf("CI      ran in: %5.1f seconds.\n", getpref('ISETValidate','tvciTime'));
% Not running this here anymore
%fprintf("Human   ran in: %5.1f seconds.\n", getpref('ISETValidate','tvhumanTime'));

%% Sometimes we have trouble because of a failure to clear variables
% This seems wrong -- DJC
%disp('Setting ieInit clear status to false. Variables not cleared on ieInit.')
%ieSessionSet('init clear',false);

%% END