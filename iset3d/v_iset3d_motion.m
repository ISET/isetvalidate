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
% Start with translation, by default is meters per frame
% For reference the Letter A is .07 x .07 meters, and -.05, .01, .56 in
% position
shiftA = .07; % one 'diagonal' of the Letter A
translationEnd = [shiftA shiftA 0]; % Arbitrary
thisR.set('camera motion translate start',[0 0 0]);
thisR.set('camera motion translate end',translationEnd);

customWRS(thisR,'camera_Trans');

% Now rotation
thisR = piRecipeCreate(useScene);
rotationMatrixStart = piRotationMatrix;
rotationMatrixEnd = piRotationMatrix;

% Camera rotation is by default absolute
desiredRotation = [0 0 30]; % Arbitrary
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

% We can of course add an actual translation if desired
thisR.set('camera motion translate start',[0 0 0]);
thisR.set('camera motion translate end',[0 .07 0]);

customWRS(thisR,'camera_Rot_Trans');


%% Now test object motion
thisR = piRecipeCreate(useScene);
thisR.hasActiveTransform = true;
getDocker(thisR); % Need CPU version

asset = 'A_O'; % could use any of the letters

% We're not using shutter times yet, so values are total desired
assetTranslation = [.1 .1 0];
piAssetMotionAdd(thisR,asset, ...
    'translation', assetTranslation);

assetRotation = [0 0 90];
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
piAssetRotate(thisR, asset, assetRotation);

customWRS(thisR,'asset_motion_movement');

%% Now test both camera and object motion
%  Start with the scene we have, that has object motion
thisR.set('camera motion translate start',[0 0 0]);
thisR.set('camera motion translate end',translationEnd);

customWRS(thisR,'asset_and_camera');

%% Try using shutter times to control position
%  this is how we do burst sequences

thisR = piRecipeCreate(useScene);
thisR.hasActiveTransform = true;
getDocker(thisR); % Need CPU version

%% Set parameters for our burst
asset = 'A_O'; % could use any of the letters
exposureTime = .001; % currently this needs to be short enough to avoid long exposure from blowing out.
exposureMultiplier = 1000; %only used for creating integer file names

numFrames = 3; % Arbitrary, > 1
totalDuration = exposureTime * numFrames;
shutterStart = 0;
epsilon = 0; % minimum offset (not currenty needed)
sceneBurst = []; % so we can check for isempty()

% We're using shutter times yet, so values are m/s
assetTranslation = [.04*exposureMultiplier .04*exposureMultiplier 0];
piAssetMotionAdd(thisR,asset, ...
    'translation', assetTranslation);

assetRotation = [0 0 45]; % Check if this is d/s so we need to multiply?
piAssetMotionAdd(thisR,asset , ...
    'rotation', assetRotation);

for ii = 1:numFrames
    shutterOpen = shutterStart + (exposureTime * (ii-1));
    shutterClose =  shutterStart + (exposureTime * ii);
    thisR.set('shutteropen', shutterOpen);
    thisR.set('shutterclose', shutterClose);

    % customWRS calls piWRS, but sets the output file name
    %           and scene name to make tracing simpler
    outputFile = sprintf('shutter_%03d_%03d',shutterOpen*exposureMultiplier, ...
        shutterClose*exposureMultiplier);

    % Now render, show, and write output file
    currentScene = customWRS(thisR,outputFile);

    if isempty(sceneBurst)
        sceneBurst = currentScene;

        % First time through take our "long" exposure
        shutterClose = shutterStart + (exposureTime*numFrames);
        thisR.set('shutterClose', shutterClose);
        outputFile = sprintf('shutter_%03d_%03d',shutterOpen*exposureMultiplier, ...
            shutterClose*exposureMultiplier);
        sceneLong = customWRS(thisR, outputFile);
    else

        sceneBurst = sceneAdd(sceneBurst, currentScene);

        % Shutter doesn't seem to affect photon count
        % so we add up the scenes as we go
        sceneLong = sceneAdd(sceneLong, sceneLong);
    end

end

[sensorLong, sensorBurst] = sceneCompare(sceneLong,sceneBurst, totalDuration);
% class of volts has to match for ssim (maybe fix in ssim?)
sensorLong.data.volts = double(sensorLong.data.volts);
sensorBurst.data.volts = double(sensorBurst.data.volts);

[ssimVal, ssimMap] = ssim(sensorLong.data.volts, sensorBurst.data.volts);

% show results:
fprintf('SSIM: %f\n',ssimVal)
figure;
imshowpair(sensorLong.data.volts,sensorBurst.data.volts,'diff')
%{
max(sensorLong.data.volts,[],'all')
max(sensorBurst.data.volts,[],'all')

mean(sensorLong.data.volts,'all')
mean(sensorBurst.data.volts,'all')
%}


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

