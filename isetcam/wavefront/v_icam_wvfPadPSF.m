% v_icam_wvfPadPSF
%
% Testing the problem with failure to pad with the
% ImageConvFrequencyDomain issue.
%

ieInit;

%% This scene produces the error.  
oi = oiCreate('human wvf');

scene = sceneCreate('slanted edge');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% Compare the opticsOTF  path.  It does not have the error.

oi = oiCreate('human wvf');

scene = sceneCreate('slanted edge');
oi = oiSet(oi,'optics name','opticsotf');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% OpticsPSF with pad value of zero

oi = oiCreate('human wvf');

scene = sceneCreate('slanted edge');
oi = oiSet(oi,'optics name','opticspsf');

oi = oiCompute(oi,scene,'pad value','zero','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
uDataPSF = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%
oi = oiCreate('human wvf');

scene = sceneCreate('slanted edge');
oi = oiSet(oi,'optics name','opticsotf');

oi = oiCompute(oi,scene,'pad value','zero','crop',false);
sz = oiGet(oi,'size');

% 
% There is a shift of one pixel between the two methods
%
% Notice that the line rolls off to zero and does not stay at the mean
% level.
uDataOTF = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

dx = uDataOTF.pos(2) - uDataOTF.pos(1);
ieNewGraphWin;
plot(uDataOTF.pos - dx,uDataOTF.data,'ro',uDataPSF.pos,uDataPSF.data,'g-');
grid on;


%% Here are other scenes I tried.  They were OK, too.

%{

scene = sceneCreate('grid lines',211);
scene = sceneCreate('line d65',127);
scene = sceneCreate('point array');
scene = sceneCreate('macbeth d65');
scene = sceneCreate('slantedEdge',128,1.33,[], [], 0.9); 

oi = oiCreate('human wvf');
oi = oiSet(oi,'optics name','opticspsf');
oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));


oi = oiCreate('human wvf');
oi = oiSet(oi,'optics name','opticsotf');
oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%}

