%% v_opticsSI
%
% Create a shift-invariant optics structure with custom PSF data.
%
% The structure is created using a set of point spread functions.  The
% point spread functions are a set of matrices defined on a grid.  THere is
% one point spread for each wavelength.  In this example, there are 31
% wavelengths (400:10:700).  The point spread functions are simply random
% numbers.  The grid is 128 x 128 with samples spaced every 0.25 microns.
% Hence, the total grid size is 32 microns on a side.
%
% See also: s_SIExamples for more of this stuff
%
% Copyright ImagEval Consultants, LLC, 2007

%%
ieInit;
tolerance = 1e-6;

%% Let's work with a small checkerboard scene
pixPerCheck = 8;
nChecks = 12;
scene = sceneCreate('checkerboard',pixPerCheck,nChecks);
wave  = sceneGet(scene,'wave');
scene = sceneSet(scene,'fov',3);

% sceneWindow(scene); pause(delay);

%% Write a file containing the relevant point spread function
% data, along with related variables.
umPerSample = [0.25,0.25];                % Sample spacing

% Point spread is a little square in the middle of the image
h = zeros(128,128); h(48:79,48:79) = 1; h = h/sum(h(:));
psf = zeros(128,128,length(wave));
for ii=1:length(wave), psf(:,:,ii) = h; end     % PSF data

% Save the data
siFile = fullfile(tempdir,'customFile.mat');
ieSaveSIDataFile(psf,wave,umPerSample,siFile);

%% Read the custom data and put it into an optics structure.
oi     = oiCreate;
optics = siSynthetic('custom',oi,siFile,fullfile(tempdir,'deleteMe'));

% Make sure the program knows you want to use shift invariant
optics = opticsSet(optics,'model','shiftInvariant');

% Attach the optics structure to the optical image structure
oi = oiSet(oi,'optics',optics);

% You can now compute using your current scene.
oi = oiCompute(oi,scene);
p = oiGet(oi,'photons');
assert( (mean(p(:)/1.180227521409805e+14) - 1) < tolerance);

%%
drawnow;
%% End