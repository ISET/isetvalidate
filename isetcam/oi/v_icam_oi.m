%% Test optical image functions
%
% Copyright Imageval LLC, 2009

%%
tolerance = 1e-6;

%% Diffraction limited simulation properties
oi  = oiCreate('diffraction limited');
tmp = oiGet(oi,'optics otf',550);
assert(abs(sum(tmp(:)))/abs(1.0850e+03 + 4.3387e-30i) -1 < 1e-4);

%%
uData = oiPlot(oi,'otf',[],550);
assert(abs(mean(abs(uData.otf(:)))/0.002697953020965 - 1) < tolerance);

uData = oiPlot(oi,'otf',[],450);
assert(abs(mean(abs(uData.otf(:)))/0.004381079676246 - 1) < tolerance);

%% Shift invariant, which defaults to diffraction limited
oi = oiCreate('shift invariant');
oiPlot(oi,'otf',[],550);
oiPlot(oi,'otf',[],450);

tmp = oiGet(oi,'optics otf',550);
assert(abs(sum(tmp(:)))/abs(1.0850e+03 + 4.3387e-30i) -1 < 1e-4);

%% Make a scene and show some oiGets and oiCompute work
scene = sceneCreate('gridlines',256);
scene = sceneSet(scene,'fov',1);
oi = oiCreate('shift invariant');
oi = oiCompute(oi,scene);

uData = oiPlot(oi,'illuminance mesh linear');
assert(isequal(size(uData.data),[320 320]));
assert(abs(mean(double(uData.data(:)))/3.073368220531811 - 1) < tolerance);

%% Check GUI control
oiWindow(oi); pause(0.2);
oiSet(oi,'gamma',1);
oiSet(oi,'gamma',0.4); pause(0.5)
oiSet(oi,'gamma',1);

%%