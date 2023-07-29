%% Calculate the number of rod absorptions to a uniform scene
%
% This is also implemented using the coneMosaicRect in the script
% s_humanRodAbsorptions.  There is a different (15 percent) in the two
% methods of calculating. To discuss why. 
%
% We simulate the rod absorptions to the LED device at its mean light
% level. Hiroshi believed that there are about 750,000 absorptions per
% second per rod for the spectral power distribution of his rig
% and a 3mm pupil.
% 
% Hiroshi Horiguchi, 2012 initiated as part of his PNAS paper on
% melanopsin.   We keep checking just for consistency.  Human calculations
% can vary with pigments, rod apertures as a function of eccentricity, and
% so forth.  But this is about right for 15 deg in the periphery.
%
% See also
%   s_humanRodAbsorptions, v_ibio_calibration*

%%
ieInit

%%
scene = sceneCreate('uniform ee');
wave  = sceneGet(scene,'wave');

% Hiroshi's rig
primaries = ieReadSpectra('LED6-Melanopsin-HH.mat',wave);
ieNewGraphWin; plotRadiance(wave,primaries);

% Add up the six primaries.
illEnergy = primaries * ones(6,1);

% apply illuminant energy to scene
scene = sceneAdjustIlluminant(scene,illEnergy);

% set luminance to the value Hiroshi used
meanluminance      = 2060; % cd/m2
scene = sceneSet(scene,'mean luminance', meanluminance);   % Cd/m2

% Not much to look at.
% sceneWindow(scene);

%% create an optical image of human eye

% This includes the lens transmission
oi = oiCreate('wvf human',3);     % Pupil diameter in mm
% oiGet(oi,'optics pupil diameter','mm')

% open an optical image.  This include the lens transmission.
oi = oiCompute(oi,scene);

% Get rid of the edges.
oi = oiCrop(oi,'border');

% Not much to look at
% oiWindow(oi);

%%  Make a pixel with a rod spectral sensitivity

% The scotopic luminosity includes the lens.  We already have the lens
% in the oi. So we divided that out in rods.mat. We assume that the macular
% pigment is not part of scotopic because, well, rods aren't in the macular
% region.
rods  = ieReadSpectra('rods.mat',wave);
ieNewGraphWin; plot(wave,rods)

%%  Make a sensor with pixels like the rods

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

% Not much to look at.
% sensorWindow(sensor); 

%% Calculate number of absorptions (electrons) per rod

roi    = sensorROI(sensor,'center');
sensor = sensorSet(sensor,'roi',roi);
elROI  = sensorGet(sensor,'roi electrons');

% mean of electron
fprintf('Absorptions: %.1f for pixel size (%.2f %.2f).  Should be near 750K\n',mean(elROI),sensorGet(sensor,'pixel size','um'));

% Check that we are within about 5 percent
assert( abs(mean(elROI)/7.5e+5 - 1) < 0.05);

%% END
