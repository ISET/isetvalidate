%% Test camera and object motion
% (maybe split them apart if we get enough tests)
%
%   v_iset3d_motion
%
% D. Cardinal, Stanford University, June, 2024

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
%{
piAssetMotionAdd(thisR,asset, ...
    'translation', assetTranslation);
piAssetMotionAdd(thisR,asset , ...
    'rotation', assetRotation);
%}
exposureTime = .005;
shutterStart = 0;
epsilon = .0001; %minimum offset

thisR.set('shutteropen', shutterStart);
thisR.set('shutterclose', shutterStart + exposureTime);

% customWRS calls piWRS, but sets the output file name
%           and scene name to make tracing simpler
scene_00_05 = customWRS(thisR,'shutter00_05');

thisR.set('shutteropen', shutterStart + exposureTime + epsilon);
thisR.set('shutterclose', shutterStart + 2*exposureTime + epsilon);

scene_06_10 = customWRS(thisR,'shutter06_10');

thisR.set('shutteropen', shutterStart);
thisR.set('shutterclose', shutterStart + 2 * exposureTime);
scene_00_10 = customWRS(thisR,'shutter00_10');

% Check to see if summed scenes look the same
scene_burst = sceneAdd(scene_00_05, scene_06_10);

% Shutter doesn't seem to affect photon count
scene_00_10 = sceneAdd(scene_00_10, scene_00_10);

[sensorLong, sensorBurst] = sceneCompare(scene_00_10,scene_burst, .0001);
[ssimVal, ssimMap] = ssim(sensorLong.data.volts, sensorBurst.data.volts);

% show results:
fprintf('SSIM: %f\n',ssimVal)
figure;
imshowpair(sensorLong.data.volts,sensorBurst.data.volts,'diff')
%{
max(sensorLong.data.volts,[],'all')
max(sensorBurst.data.volts,[],'all')
%}

[sensorLong1, sensorLong2]= sceneCompare(scene_00_10,scene_00_10, .1);
[ssimVal, ssimMap] = ssim(sensorLong1.data.volts, sensorLong2.data.volts);
% show results:
fprintf('SSIM for identical: %f\n',ssimVal)
figure;
imshowpair(sensorLong1.data.volts,sensorLong2.data.volts,'diff')
%imshowpair(sensorLong.data.volts,sensorBurst.data.volts,'falsecolor')


%% Customize output file & scene name for easier tracing
function scene = customWRS(thisR, outputName)
    [p, ~, e] = fileparts(thisR.outputFile);
        outFileName = ['Test_' outputName e];
    thisR.outputFile = fullfile(p,outFileName);
    thisR.name = ['Test: ' outputName];
    
    % Now run the regular wrs
    % Make sure to turn off mean luminance!!
    scene = piWRS(thisR, 'mean luminance', -1);
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

