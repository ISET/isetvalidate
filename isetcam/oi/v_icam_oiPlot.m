%% Script for testing the oiPlot routine
%
% Put oiPlot through its paces.
%
% Copyright Imageval Consulting, LLC, 2015

ieInit;

%% Initialize the oi structure
scene = sceneCreate;
scene = sceneSet(scene,'fov',4);
oi = oiCreate; oi = oiCompute(oi,scene);

%%
[uData, g] = oiPlot(oi,'vline',[20 20]);
drawnow;
%%
[uData, g] = oiPlot(oi,'hline',[20 20]);
drawnow;
%%
[uData, g] = oiPlot(oi,'illuminance hline',[20 20]);
rows = round(oiGet(oi,'rows')/2);
drawnow;
%%
uData = oiPlot(oi,' irradiance hline',[1,rows]);
drawnow;
%%
uData = oiPlot(oi,'illuminance fft hline',[1,rows]);
drawnow;
%%
uData = oiPlot(oi,'contrast hline',[1,rows]);
drawnow;
%%
uData = oiPlot(oi,'irradiance image with grid',[],40);
drawnow;
%%
uData = oiPlot(oi,'irradiance image wave',[],500,40);
drawnow;
%%
uData = oiPlot(oi,'irradiance fft',[],450);
drawnow;
%%  Get some roiLocs
% uData = oiPlot(oi,'irradiance energy roi');

%%
uData = oiPlot(oi,'psf 550','um');
drawnow;
%%
uData = oiPlot(oi,'otf 550','um');
drawnow;
%%
uData = oiPlot(oi,'ls wavelength');
drawnow;
%%
drawnow;
%% End