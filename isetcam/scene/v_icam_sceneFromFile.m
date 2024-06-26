%% Validation script for sceneFromFile
%
% Makes and deletes a small test scene in the local directory
%
% BW

%%
ieInit;

% Use the local directory that is not included in the git repository.
cd(fullfile(isetRootPath,'local'));

%% Create and read a scene variable from the file

% This is the new feature
scene = sceneCreate;
save('testS','scene');

s = sceneFromFile('testS');
assert(isequal(s,scene));  % Should be the same

%%  Read in a mat multispectral file

% Check that the old stuff worked
fName = 'StuffedAnimals_tungsten-hdrs.mat';
scene = sceneFromFile(fName,'multispectral');
mn = sceneGet(scene,'mean luminance');
assert(abs(mn - 30.04707249) < 1e-5);

%% Create a file from RGB data
RGB = ieClip(255*rand(10,10,3),0,255);
scene = sceneFromFile(RGB,'rgb',100,'lcdExample');
sceneWindow(scene);

%% Now try sceneToFile with the scene data

% This tests whether the new 'fov' and 'dist' read/write works
vExplained = sceneToFile('testS2',scene);
scene2 = sceneFromFile('testS2','multispectral');

wave = sceneGet(scene,'wave');
q1 = sceneGet(scene,'photons',wave(10));
q2 = sceneGet(scene2,'photons',wave(10));
assert(sceneGet(scene,'fov') == sceneGet(scene2,'fov'))

% ieNewGraphWin; title('Validating sceneToFile');
% assert( max(abs(q1(1:10:end)-q2(1:10:end))) < 1e-5);
% plot(q1(1:10:end),q2(1:10:end),'.'); 
% grid on; xlabel('scene 1'); ylabel('scene 2');

%% Now try on a jpg image
fullFileName = which('eagle.jpg');
scene = sceneFromFile(fullFileName,'rgb',100,'lcdExample');
assert(abs(scene.wAngular - 15.5233) < 1e-3);

% sceneWindow(scene);

%% Clean up
if exist('testS.mat','file'), delete('testS.mat'); end

%%
