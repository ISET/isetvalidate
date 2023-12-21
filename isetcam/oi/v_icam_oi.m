%% Test optical image functions
%
% Copyright Imageval LLC, 2009

%% Diffraction limited simulation properties
oi  = oiCreate('diffraction limited');
tmp = oiGet(oi,'optics otf',550);
assert(abs(sum(tmp(:)))/abs(1.0850e+03 + 4.3387e-30i) -1 < 1e-4);

oiPlot(oi,'otf',[],550);
oiPlot(oi,'otf',[],450);

%% Shift invariant, which defaults to diffraction limited
oi = oiCreate('shift invariant');
oiPlot(oi,'otf',[],550);
oiPlot(oi,'otf',[],450);

tmp = oiGet(oi,'optics otf',550);
assert(abs(sum(tmp(:)))/abs(1.0850e+03 + 4.3387e-30i) -1 < 1e-4);

%% Human optics
if exist('isetbioRootPath','file')
    oi = oiCreate('human mw');
    oiPlot(oi,'psf',[],420);
    oiPlot(oi,'psf',[],550);
end

%% Make a scene and show some oiGets and oiCompute work
scene = sceneCreate('gridlines',[256 256]);
scene = sceneSet(scene,'fov',1);
oi = oiCreate('shift invariant');
oi = oiCompute(oi,scene);

oiWindow(oi);
% oiPlot(oi,'illuminance mesh linear');

%% Check GUI control
oiWindow(oi); pause(0.2);

oiSet(oi,'gamma',1);
oiSet(oi,'gamma',0.4); pause(0.5)
oiSet(oi,'gamma',1);

%%