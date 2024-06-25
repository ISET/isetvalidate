%% Test camera and object motion
% (maybe split them apart if we get enough tests)
%
%   v_iset3d_motion
%

%%
ieInit
if ~piDockerExists, piDockerConfig; end

fprintf('Testing camera and object motion\n');

%% Start with a simple scene & asset(s)
%  and set basic parameters for rendering

useScene = 'lettersatdepth';
thisR = piRecipeCreate(useScene);

%% First test camera motion
% Start with translation
translationEnd = [.05 .05 0]; % Arbitrary
thisR.set('camera motion translate start',[0 0 0]);
thisR.set('camera motion translate end',translationEnd);

customWRS(thisR,'camera_Trans');

% Now rotation
thisR = piRecipeCreate(useScene);
rotationMatrixStart = piRotationMatrix;
rotationMatrixEnd = piRotationMatrix;

desiredRotation = [0 0 10]; % Arbitrary
rotationMatrixEnd(1,1) = rotationMatrixStart(1,1) ...
    + desiredRotation(3);
rotationMatrixEnd(1,2) = rotationMatrixStart(1,2) ...
    + desiredRotation(2);
rotationMatrixEnd(1,3) = rotationMatrixStart(1,3) ...
    + desiredRotation(1);

thisR.set('camera motion rotate start',rotationMatrixStart);
thisR.set('camera motion rotate end',rotationMatrixEnd);

%%%% NOTE: We get an error in piWrite() here, because
%          it wants a position for the ActiveTransform
%    So we add a null translate and it runs...
thisR.set('camera motion translate start',[0 0 0]);
thisR.set('camera motion translate end',[0 0 0]);

customWRS(thisR,'camera_Rot_Trans');


%% Now test object motion
thisR = piRecipeCreate(useScene);
thisR.hasActiveTransform = true;
getDocker(thisR); % Need CPU version

asset = 'A_O'; % could use any of the letters
assetTranslation = [.3 .3 0];
piAssetMotionAdd(thisR,asset, ...
    'translation', assetTranslation);

assetRotation = [0 0 10];
piAssetMotionAdd(thisR,asset , ...
    'rotation', assetRotation);

customWRS(thisR,'asset_motion');

%% Now test object motion with standard positioning
%%%% NOTE: Adding an AssetTranslate here
%          generates the error on line 339 of
%          piGeometryWrite, which assumes that
%          if you have any motion translations
%          that all translations are motion
%%piAssetTranslate(thisR,asset,[.1 .1 0]);

% What happens if we simply have a rotation
piAssetRotate(thisR, asset, [15 15 15]);

customWRS(thisR,'asset_motion_movement');

%% Now test both camera and object motion
%  Start with the scene we have, that has object motion
thisR.set('camera motion translate start',[0 0 0]);
thisR.set('camera motion translate end',translationEnd);

customWRS(thisR,'asset_and_camera');

%% Try using shutter times to control position
%  this is how we are trying to do burst sequences
thisR = piRecipeCreate(useScene);
piAssetMotionAdd(thisR,asset, ...
    'translation', assetTranslation);
piAssetMotionAdd(thisR,asset , ...
    'rotation', assetRotation);

thisR.set('shutteropen', .00);
thisR.set('shutterclose', .05);
customWRS(thisR,'shutter00_05');

thisR.set('shutteropen', .05);
thisR.set('shutterclose', .10);
customWRS(thisR,'shutter05_10');

thisR.set('shutteropen', .00);
thisR.set('shutterclose', .10);
customWRS(thisR,'shutter00_10');

%% Customize output file & scene name for easier tracing
function customWRS(thisR, outputName)
    [p, ~, e] = fileparts(thisR.outputFile);
        outFileName = ['Test_' outputName e];
    thisR.outputFile = fullfile(p,outFileName);
    thisR.name = ['Test: ' outputName];
    
    % Now run the regular wrs
    piWRS(thisR);
end

%% Select correct version of PBRT
%% Set up correct docker image
% isetdocker ignores the docker container we pass and uses presets
% so for now we have to clear out the container
function useDocker = getDocker(thisR)

% TBD: Fix so we only reset when switching!
reset(isetdocker);
if thisR.hasActiveTransform
    % NOTE: Need to use a cpu version of pbrt for this case
    dockerCPU = isetdocker('preset','orange-cpu');
    useDocker = dockerCPU;
else
    dockerGPU = isetdocker('preset','remoteorange');
    useDocker = dockerGPU;
end
end

