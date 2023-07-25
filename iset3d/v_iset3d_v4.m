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
disp('*** DOCKER -- v_iset3d_dockerWrapper');
setpref('ISET3d', 'tvdockerStart', tic);
try
    v_iset3d_dockerWrapper('length','short');
    setpref('ISET3d', 'tvdockerTime', toc(getpref('ISET3d', 'tvdockerStart', 0)));
catch
    warning('Docker Wrapper test failed');
    disp('Make sure you have a remote image set up before running');
    setpref('ISET3d', 'tvdockerTime', -1);
end

%% Depth validation
disp('*** DEPTH -- v_iset3d_scenedepth')
setpref('ISET3d', 'tvdepthStart', tic);
try
    v_iset3d_scenedepth;               % Gets the depth map
    setpref('ISET3d', 'tvdepthTime', toc(getpref('ISET3d', 'tvdepthStart', 0)));
catch ME
    warning('Depth failed.\n');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d', 'tvdepthTime', -1);
end

%% Omni camera (e.g. one with a lens)
disp('v_iset3d_omni')
setpref('ISET3d', 'tvomniStart', tic);
try
    v_iset3d_omni;          
    setpref('ISET3d', 'tvomniTime', toc(getpref('ISET3d', 'tvomniStart', 0)));
catch ME
    warning('Omni failed.\n');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d', 'tvomniTime', -1);
end

%% Assets
disp('v_iset3d_assets')
setpref('ISET3d', 'tvassetsStart', tic);
try
    v_iset3d_assets;          % Get the zmap
    setpref('ISET3d', 'tvassetsTime', toc(getpref('ISET3d', 'tvassetsStart', 0)));
catch ME
    warning('Macbeth failed.\n');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d', 'tvassetsTime', -1);
end

%% Demo working with materials
disp('*** MATERIALS -- v_iset3d_materials')
setpref('ISET3d', 'tvmaterialStart', tic);
v_iset3d_materials;
setpref('ISET3d', 'tvmaterialTime', toc(getpref('ISET3d', 'tvmaterialStart', 0)));

%% Demo working with lights
disp('*** LIGHTS -- t_piIntro_light')
setpref('ISET3d', 'tvlightStart', tic);
try
    t_piIntro_light;
    setpref('ISET3d', 'tvlightTime', toc(getpref('ISET3d', 'tvlightStart', 0)));
catch ME
    warning('piIntro_Light failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d', 'tvlightTime', -1);
end

%% Our Intro Demo
disp('*** INTRO -- t_piIntro')
setpref('ISET3d', 'tvpbrtStart', tic);
try
    t_piIntro;
    setpref('ISET3d', 'tvpbrtTime', toc(getpref('ISET3d', 'tvpbrtStart', 0)));
catch ME
    warning('piIntro failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d', 'tvpbrtTime', -1);
end

%%  Translate and Rotate the camera
disp('*** CAMERA POSITION -- t_cameraPosition')
setpref('ISET3d', 'tvcampositionStart', tic);
t_cameraPosition;
setpref('ISET3d', 'tvcampositionTime', toc(getpref('ISET3d', 'tvcampositionStart', 0)));

%% Various renders of the Chess Set
disp('*** CHESS SET -- t_piIntro_chess')
setpref('ISET3d', 'tvchessStart', tic);
try
    t_piIntro_chess;
    setpref('ISET3d', 'tvchessTime', toc(getpref('ISET3d', 'tvchessStart', 0)));
catch ME
    warning('chess set failed')
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d', 'tvchessTime', -1);
end

%% Validate some recipes
disp('*** RECIPES -- v_iset3d_recipeValidation')
setpref('ISET3d', 'tvrecipeStart', tic);
try
    v_iset3d_recipeValidation;
    setpref('ISET3d', 'tvrecipeTime', toc(getpref('ISET3d', 'tvrecipeStart', 0)));
catch ME
    warning('recipe validation failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d','tvrecipeTime', -1);
end

%% Check objectBegin/End implementation
disp('*** RECIPES -- v_iset3d_objectInstance')
setpref('ISET3d', 'tvobjectStart', tic);
try
    v_iset3d_objectInstance;
    setpref('ISET3d', 'tvobjectTime', toc(getpref('ISET3d', 'tvobjectStart', 0)));
catch ME
    warning('object instance validation failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d','tvobjectTime', -1);
end

disp('*** RECIPES -- v_iset3d_recipeValidation')
setpref('ISET3d', 'tvrecipeStart', tic);
try
    v_iset3d_recipeValidation;
    setpref('ISET3d', 'tvrecipeTime', toc(getpref('ISET3d', 'tvrecipeStart', 0)));
catch ME
    warning('recipe validation failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d','tvrecipeTime', -1);
end

%%  test our skymap specific API
disp('*** SKYMAPS -- v_iset3d_skymap')
setpref('ISET3d', 'tvskymapStart', tic);
v_iset3d_skymap;
setpref('ISET3d', 'tvskymapTime', toc(getpref('ISET3d', 'tvskymapStart', 0)));

% TEST Line used FOR DEBUGGING COLOR OUTPUT
% setpref('ISET3d', 'tvskymapTime', -1);

%% Textures 
disp('*** TEXTURES -- t_piIntro_texture')
setpref('ISET3d', 'tvtextureStart', tic);
try
    t_piIntro_texture;
    setpref('ISET3d', 'tvtextureTime', toc(getpref('ISET3d', 'tvtextureStart', 0)));
catch ME
    warning('texture validation failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d','tvtextureTime', -1);
end

%% Eye 
disp('*** SCENE_EYE -- v_iset3d_sceneEye')
setpref('ISET3d', 'tveyeStart', tic);
try
    v_iset3d_sceneEye;
    setpref('ISET3d', 'tveyeTime', toc(getpref('ISET3d', 'tveyeStart', 0)));
catch ME
    warning('sceneEye validation failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d','tveyeTime', -1);
end

%% Text 
disp('*** TEXT -- v_iset3d_text')
setpref('ISET3d', 'tvtextStart', tic);
try
    v_iset3d_text;
    setpref('ISET3d', 'tvtextTime', toc(getpref('ISET3d', 'tvtextStart', 0)));
catch ME
    warning('Text validation failed');
    warning(ME.identifier,'%s',ME.message);
    setpref('ISET3d','tvtextTime', -1);
end

%% Need to add other new validation scripts
% sceneEye, text, worldCoordinates

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
vprintf('Material:   ', getpref('ISET3d','tvmaterialTime'));
vprintf('Object:     ', getpref('ISET3d','tvobjectTime'));
vprintf('Light:      ', getpref('ISET3d','tvlightTime'));
vprintf('Cam Pos.:   ', getpref('ISET3d','tvcampositionTime'));
vprintf('Chess Set:  ', getpref('ISET3d','tvchessTime'));
vprintf('Skymap:     ', getpref('ISET3d','tvskymapTime'));
vprintf('Texture:    ', getpref('ISET3d','tvtextureTime'));
vprintf('Recipes:    ', getpref('ISET3d','tvrecipeTime'));
vprintf('Scene Eye:  ', getpref('ISET3d','tveyeTime'));
vprintf('Text:       ', getpref('ISET3d','tvtextTime'));

%% END

function vprintf(aString, aTime)
    if aTime < 0
        cprintf('err', sprintf([aString 'FAILED.\n']));
    else
        fprintf([aString '%5.1f seconds.\n'], aTime);
    end
end