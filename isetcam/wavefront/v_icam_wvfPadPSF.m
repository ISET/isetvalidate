% v_icam_wvfPadPSF
%
% Testing the problem with failure to pad with the
% ImageConvFrequencyDomain issue.
%

%%  Set up the scene
ieInit;

% When the size is even, no shift.  When the size is odd, there is a
% one pixel shift.  See this by comparing the line d65 cases.

% But for this scene the size is always constructed odd, even when we
% specify even!  Check why that is.
% scene = sceneCreate('slanted edge');

% The agreement is better as imSize is smaller
% imSize = 512; scene = sceneCreate('grid lines',imSize,imSize/4);
% scene = sceneCreate('macbeth d65');
scene = sceneCreate('line d65',255);  % Shift
% scene = sceneCreate('line d65',256);  % No shift

scene = sceneSet(scene,'fov',1);

%% This scene produced the error when using the old code

oi = oiCreate('human wvf');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% With the old code, the plot rolls off to zero and does not stay at
% the mean level.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% Compare the opticsOTF  path.  It does not have the error.

oi = oiCreate('human wvf');

oi = oiSet(oi,'optics name','opticsotf');

oi = oiCompute(oi,scene,'pad value','mean','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% OpticsPSF with pad value of zero

oi = oiCreate('human wvf');

oi = oiSet(oi,'optics name','opticspsf');

oi = oiCompute(oi,scene,'pad value','zero','crop',false);
sz = oiGet(oi,'size');

% Notice that the line rolls off to zero and does not stay at the mean
% level.
uDataPSF = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

oi = oiCreate('human wvf');
oi = oiSet(oi,'optics name','opticsotf');
oi = oiCompute(oi,scene,'pad value','zero','crop',false);
sz = oiGet(oi,'size');
uDataOTF = oiPlot(oi,'illuminance hline',round([1 sz(2)/2]));

%% When size of photons is odd, there is a shift of 1 pixel.

ieNewGraphWin;
plot(uDataOTF.pos,uDataOTF.data,'ro',uDataPSF.pos,uDataPSF.data,'gs');
grid on;  title('No shift'); legend({'OTF','PSF'});


%% END

