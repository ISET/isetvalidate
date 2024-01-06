%% Validation for scenes
%
% Scripts related to scenes
%
% Additional scripts of interest
%
%  s_XYZilluminantTransforms
%  s_sceneReflectanceCharts
%  s_sceneFromRGB
%  scenePlotTest
%

%% Check GUI control
scene = sceneCreate;
sceneWindow(scene);
sceneSet(scene,'gamma',0.5);
sceneSet(scene,'gamma',1);

%% Check sceneCombine
scene = sceneCombine(sceneCreate,sceneCreate,'direction','horizontal');
sceneWindow(scene);
drawnow;

%%

