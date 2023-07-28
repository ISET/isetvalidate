%% Calculate the number of rod absorptions to a uniform scene
%
% This should be updated for coneMosaicRect.  For now, we are using
% sensor calculations.
%
% We simulate the rod absorptions to the LED device at its mean light
% level. Hiroshi believed that there are about 750,000 absorptions per
% second per rod for the spectral power distribution of his rig
% and a 3mm pupil.
% 
% Hiroshi Horiguchi, 2012 initiated as part of his PNAS paper on
% melanopsin.
%
% See also
%   v_ibio_calibration*

%%
ieInit

%%
scene = sceneCreate('uniform ee');
wave  = sceneGet(scene,'wave');


primaries = ieReadSpectra('LED6-Melanopsin-HH.mat',wave);
ieNewGraphWin; plotRadiance(wave,primaries);

% % multiply your primaries by illEnergy
illEnergy = primaries * ones(6,1);

% apply illuminant energy to scene
scene = sceneAdjustIlluminant(scene,illEnergy);
% sceneGet(scene,'mean luminance') % you'll probably get 100 Cd/m2.

% % set luminance you desire
meanluminance      = 2060; % cd/m2
scene = sceneSet(scene,'mean luminance', meanluminance);   % Cd/m2
% sceneWindow(scene);

%% create an optical image of human eye

% This includes the lens transmission
oi = oiCreate('wvf human',3);     % Pupil diameter in mm
oiGet(oi,'optics pupil diameter','mm')

% open an optical image window
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');
oiWindow(oi);

%%  Make a pixel with a rod spectral sensitivity

% The scotopic luminosity includes the lens.  We already have the lens
% in the oi. So we divide that out
rods  = ieReadSpectra('rods.mat',wave);
ieNewGraphWin; plot(wave,rods)

%%  Make sensor like a rod mosaic

% The pixel size and the pupil size matter a lot for absorption counts
pixSize = 2.22*1e-6;   % Meters % 15 deg ecc. Curio 1993 is 2.22

sensor = sensorCreateIdeal('monochrome');
sensor = sensorSet(sensor,'pixel size',pixSize);
sensor = sensorSet(sensor,'pixel voltageSwing', 300); % No saturation
sensor = sensorSet(sensor,'pixel fill factor',1);  % Fraction
sensor = sensorSet(sensor,'autoexposure',0);   % Off
sensor = sensorSet(sensor,'exposureTime',1);   % Seconds
sensor = sensorSet(sensor,'filter spectra',rods);
sensor = sensorSet(sensor,'filter names',{'wrod'});

sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor); 

%% Calculate number of absorptions (electrons) per rod

roi    = sensorROI(sensor,'center');
sensor = sensorSet(sensor,'roi',roi);
elROI  = sensorGet(sensor,'roi electrons');

% mean of electron
fprintf('Absorptions: %.1f for pixel size (%.2f %.2f)\n',mean(elROI),sensorGet(sensor,'pixel size','um'));

%% END