%% Verify omni camera model in PBRT
%
% This is the most general camera model we have that also includes
% microlens modeling at the ray level (not wave).
%
% D. Cardinal, Feb, 2022
%
% See also
%   piIntro_lens

%% Initialize

ieInit;
if ~piDockerExists, piDockerConfig; end

%%  Scene and light
thisR = piRecipeCreate('Cornell_Box');

% There is a distant light by default.
thisR.set('lights','all','delete');

lightName = 'from camera';
ourLight = piLightCreate(lightName,...
                        'type','distant',...
                        'specscale',10);
thisR.set('lights', ourLight,'add');
thisR.set('skymap','room.exr');

thisR.set('object distance',0.5);

% No lens or omnni camera. Just a pinhole to render a scene radiance
thisR.camera = piCameraCreate('pinhole'); 
scene = piWRS(thisR,'name','pinhole test');

%% Omni with a standard double Gauss lens

thisR.set('object distance',3);
thisR.camera = piCameraCreate('omni','lens file','dgauss.22deg.12.5mm.json');

thisR.set('film diagonal',5); % mm
if exist('ilensRootPath','file'), thisR.get('film distance','mm');
else, disp('Try adding isetlens to your path');
end
piWRS(thisR,'name','dgauss test');


%% Omni with a fisheye lens

% Create a list of lens files in ISETCam data/lens
lList = lensList('quiet',true);

% Examples
% ll = 8;   % dgauss.22deg.3.0mm.json
% ll = 16;  % fisheye.87deg.12.5mm.json
% ll = 19;  % fisheye.87deg.6.0mm.json

ll = 18;    % fisheye.87deg.50.0mm.json

% Move the camera back a bit to capture more of the scene
thisR.set('object distance',10);
thisR.camera = piCameraCreate('omni', 'lens file',lList(ll).name);
thisR.set('skymap','room.exr');
oi = piWRS(thisR,'name','fisheye test');

%% Denoise
oi = piAIdenoise(oi);
oi = oiSet(oi,'name','fisheye denoised test');
ieReplaceObject(oi); 
oiWindow;

%% END



