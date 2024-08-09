%% v_iset3d_tiny_simpleScene
%
% Confirm that we can run a simple scene with the Docker call on a
% remote GPU.

%% Start up ISET and check that docker is configured 

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the recipe

thisR = piRecipeDefault('scene name','SimpleScene');
    
%% Set the render quality

thisR.set('film resolution',[256 256]);
thisR.set('rays per pixel',64);
thisR.set('n bounces',2); % Number of bounces traced for each ray

thisR.set('render type',{'radiance','depth'});

% The main way we write, render and show the recipe.  The render flag
% is optional, and there are several other optional piWRS flags.
scene = piWRS(thisR,'show',false);

% Make sure there are data in the scene
assert(sceneGet(scene,'mean luminance') - 100 < 1e-2);

%% By default, we have also computed the depth map, so we can render it

assert(abs(sceneGet(scene,'distance')/11.867 - 1.0) < 1e-3);

fprintf('*** Rendered SimpleScene.\n\n\n');

%% END