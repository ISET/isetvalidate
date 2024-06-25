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
thisR = piRecipeCreate('MacBethChart');

%% First test camera motion
% Start with translation
translationEnd = [1 1 0]; % Arbitrary
thisR.set('camera motion translate start',[0 0 0]);
thisR.set('camera motion translate end',translationEnd);

piWRS(thisR);

% Now rotation
thisR = piRecipeCreate('MacBethChart');
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

piWRS(thisR);


%% Now test object motion
piAssetMotionAdd(obj.thisR,ourMotion{1}, ...
    'translation', ourMotion{2});

%% Now test both camera and object motion

%% Select correct version of PBRT
%% Set up correct docker image
% isetdocker ignores the docker container we pass and uses presets
% so for now we have to clear out the container

function useDocker = getDocker()

% TBD: Fix so we only reset when switching!
reset(isetdocker);
if scenario.allowsObjectMotion
    % NOTE: Need to use a cpu version of pbrt for this case
    dockerCPU = isetdocker('preset','orange-cpu');
    useDocker = dockerCPU;
else
    dockerGPU = isetdocker('preset','remoteorange');
    useDocker = dockerGPU;
end
end


