% v_icam_wvfPadPSF
%
% Testing the problem with failure to pad with the
% ImageConvFrequencyDomain issue.
%

% This scene produces the error.  
oi = oiCreate('human wvf');

%%
scene = sceneCreate('slanted edge');


oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% This scene is OK.
scene = sceneCreate('macbeth d65');
oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% There is no roll off to zero with this scene.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% Here are other scenes I tried.  They were OK, too.

%{
scene = sceneCreate('grid lines');
scene = sceneCreate('line d65');
scene = sceneCreate('point array');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%}

%% Compare the opticsOTF  path.  It does not have the error.

oi = oiCreate('human wvf');

scene = sceneCreate('slanted edge');
oi = oiSet(oi,'optics name','opticsotf');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% But opticsPSF does

oi = oiCreate('human wvf');

scene = sceneCreate('slanted edge');
oi = oiSet(oi,'optics name','opticspsf');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%%
