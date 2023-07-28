%% ISET3d (v4) validation script
%
%    v_iset3d_v4
%
% Validation and Tutorial scripts.  When these all run, it is a partial
% validation of the code.  More specific unit tests are still needed.
%
% Timing for each script is included. Times of -1 mean that the script
% failed and the summary line will be printed in red.
%
% ZL,BW, DJC
%

%%
setpref('ISET3d', 'benchmarkstart', cputime); % if I just put it in a variable it gets cleared:(
setpref('ISET3d', 'tStart', tic);

%% Basic
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Quick version of DockerWrapper tests
runTest('v_iset3d_dockerWrapper','docker','*** DOCKER -- v_iset3d_dockerWrapper', ...
    'Docker Wrapper test failed\n');

%% Depth validation
runTest('v_iset3d_scenedepth','depth','*** DEPTH -- v_iset3d_scenedepth', ...
    'Depth failed\n');

%% Omni camera (e.g. one with a lens)
runTest('v_iset3d_omni', 'omni','*** OMNI -- v_iset3d_omni',...
    'Omni failed.\n');


%% Assets
runTest('v_iset3d_assets','assets','*** ASSETS -- v_iset3d_assets',...
    'Asset validation failed.\n');

%% Demo working with materials
runTest('v_iset3d_materials','material','*** MATERIALS -- v_iset3d_materials', ...
    'Material validation failed.\n');

%% Demo working with lights
runTest('t_piIntro_light','light', '*** LIGHTS -- t_piIntro_light', ...
    'piIntro_Light failed');

%% Our Intro Demo
runTest('t_piIntro','pbrt','*** INTRO -- t_piIntro', ...
    'piIntro failed');

%%  Translate and Rotate the camera
runTest('t_cameraPosition','camposition','*** CAMERA POSITION -- t_cameraPosition', ...
    'Camera Position failed.\n');

%% Validate some recipes
runTest('v_iset3d_recipeValidation','recipe','*** RECIPES -- v_iset3d_recipeValidation', ...
    'recipe validation failed');

%% Check objectBegin/End implementation
runTest('v_iset3d_objectInstance','object','*** RECIPES -- v_iset3d_objectInstance', ...
    'object instance validation failed.\n');

%%  test our skymap specific API
runTest('v_iset3d_skymap','skymap','*** SKYMAPS -- v_iset3d_skymap', ...
    'Skymap Validation Failed.\n');

%% Textures
runTest('t_piIntro_texture','texture','*** TEXTURES -- t_piIntro_texture',...
    'Texture validation failed');

%% Eye
runTest('v_iset3d_sceneEye', 'eye', '*** SCENE_EYE -- v_iset3d_sceneEye', ...
    'sceneEye validation failed');

%% Text
runTest('v_iset3d_text','text','*** TEXT -- v_iset3d_text', ...
    'Text validation failed.\n');

% World Coordinates
runTest('v_iset3d_worldCoordinates','world','*** WORLD -- v_iset3d_worldCoordinates',...
    'World Coordinate Validation Failed.\n');

%% Summary
tTotal = toc(getpref('ISET3d','tStart'));
afterTime = cputime;
beforeTime = getpref('ISET3d', 'benchmarkstart', 0);
glData = opengl('data');
disp(strcat("v_ISET3d-v4 (LOCAL) ran  on: ", glData.Vendor, " ", glData.Renderer, "with driver version: ", glData.Version));
disp(strcat("v_ISET3d-v4 (LOCAL) ran  in: ", string(afterTime - beforeTime), " seconds of CPU time."));
disp(strcat("v_ISET3d-v4 ran  in: ", string(tTotal), " total seconds."));
disp('---------');
vprintf('Docker:     ', getpref('ISET3d','tvdockerTime'));
vprintf('Depth:      ', getpref('ISET3d','tvdepthTime'));
vprintf('Omni:       ', getpref('ISET3d','tvomniTime'));
vprintf('Assets:     ', getpref('ISET3d','tvassetsTime'));
vprintf('Intro:      ', getpref('ISET3d','tvpbrtTime'));
vprintf('Material:   ', getpref('ISET3d','tvmaterialTime'));
vprintf('Object:     ', getpref('ISET3d','tvobjectTime'));
vprintf('Light:      ', getpref('ISET3d','tvlightTime'));
vprintf('Cam Pos.:   ', getpref('ISET3d','tvcampositionTime'));
%vprintf('Chess Set:  ', getpref('ISET3d','tvchessTime'));
vprintf('Skymap:     ', getpref('ISET3d','tvskymapTime'));
vprintf('Texture:    ', getpref('ISET3d','tvtextureTime'));
vprintf('Recipes:    ', getpref('ISET3d','tvrecipeTime'));
vprintf('Scene Eye:  ', getpref('ISET3d','tveyeTime'));
vprintf('Text:       ', getpref('ISET3d','tvtextTime'));
vprintf('World:      ', getpref('ISET3d','tvworldTime'));

%% END


function runTest(scriptName, alias, startText, warningText)

disp(startText)
setpref('ISET3d', ['tv' alias 'Start'], tic);
try
    eval(scriptName);
    setpref('ISET3d', ['tv' alias 'Time'], toc(getpref('ISET3d', ['tv' alias 'Start'], 0)));
catch ME
    warning(warningText);
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d',['tv' alias 'Time'], -1);
end

end

function vprintf(aString, aTime)
if aTime < 0
    cprintf('err', sprintf([aString 'FAILED.\n']));
else
    fprintf([aString '%5.1f seconds.\n'], aTime);
end
end