function varargout = v_ibio_wvfDiffractionPSF(varargin)
%
% Checks that diffraction-limited PSFs are correct.
%
% Compares  monochromatic PSFs computed from Zernike coefficients in this
% toolbox with those in PTB and ISET. The curves/points in each lineplot
% figure should overlay.
%
% At the end, we calculate a slice through the PSF for each wavelength.
% Illustrates how to create lines with appropriate spectral colors.
%
% (c) Wavefront Toolbox Team, 2012
    varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)

%% Initialize
close all;

% Tolerance fraction
toleranceFraction = 0.0002;

%% Some informative text
UnitTest.validationRecord('SIMPLE_MESSAGE', 'Check diffraction limited PSFs.');

%% Compare pointspread function in wvf with psf in Psych Toolbox

% When the Zernike coefficients are all zero, the wvfCompute code should
% return the diffraction limited PSF.  We test whether this works by
% comparing to the diffraction limited PSF implemented in the PTB routine
% AiryPattern.

% Set up default wvf parameters for the calculation 
wvf0 = wvfCreate;

% Specify the pupil size for the calculation
calcPupilMM = 3;
wvf0 = wvfSet(wvf0,'calc pupil size',calcPupilMM);

% Plotting ranges for MM, UM, and Minutes of angle
maxMM = 1;
maxUM = 20;
maxMIN = 2;

% Which wavelength to plot
wList = wvfGet(wvf0,'calc wave');

%% Calculate the PSF, normalized to peak of 1

% This function computes the PSF by first computing the pupil function.  In
% the default wvf object, the Zernicke coefficients match diffraction.  By
% default, 'humanlca' is false for the wvfCompute function, but we set it
% here for clarity as to what we are doing.
wvf0 = wvfCompute(wvf0,'humanlca',false);

% Make sure psf computed this way (with zcoeffs zeroed) matches
% what is returned by our internal get of diffraction limited psf.
psf = wvfGet(wvf0,'psf');

% We make it easy to simply calculate the diffraction-limited psf of the
% current structure this way.  Here we make sure that there is no
% difference. This pretty much has to work, because what the 'diffraction
% psf' get is doing is setting the zcoeffs to zero in a tmp wvf structure
% that is otherwise like the passed one, and otherwise just doing the
% wvfCompute on that structure.
diffpsf = wvfGet(wvf0,'diffraction psf');
UnitTest.assertIsZero(max(abs(psf(:)-diffpsf(:))),'Internal computation of diffraction limited psf',0);

% Verify that the calculated and measured wavelengths are the same
calcWavelength = wvfGet(wvf0,'wavelength');
measWavelength = wvfGet(wvf0,'measured wavelength');
UnitTest.assertIsZero(max(abs(measWavelength(:)-calcWavelength(:))),'Measured and calculation wavelengths compare',0);

%% Plots 

% Make a graph of the PSF within maxUM of center
wvfPlot(wvf0,'psf','unit','um','wave',wList,'plot range',maxUM);

% Make a graph of the PSF within 2 arc min
wvfPlot(wvf0,'psf angle','unit','min','wave',wList,'plot range',maxMIN);

%% Plot the middle row of the psf, scaled to peak of 1
wvfPlot(wvf0,'1d psf angle normalized','unit','min','wave',wList,'plot range',maxMIN);
hold on

% Get parameters needed for plotting comparisons with PTB, below
arcminutes       = wvfGet(wvf0,'psf angular samples','min',wList);
arcminpersample  = wvfGet(wvf0,'ref psf sample interval');
arcminpersample1 = wvfGet(wvf0,'psf arcmin per sample',wList);
arcminpersample2 = wvfGet(wvf0,'psf angle per sample',[],wList);
if (arcminpersample1 ~= arcminpersample)
    error('PSF sampling not constant across wavelengths');
end
if (arcminpersample2 ~= arcminpersample1)
    error('Default units of get on ''psfanglepersample'' unexpectedly changed');
end
ptbSampleIndex = find(abs(arcminutes) < 2);
radians = (pi/180)*(arcminutes/60);

% Compare to what we get from PTB AiryPattern function -- should match
ptbPSF = AiryPattern(radians,calcPupilMM ,calcWavelength);
plot(arcminutes(ptbSampleIndex),ptbPSF(ptbSampleIndex),'b','LineWidth',2);
xlabel('Arc Minutes');
ylabel('Normalized PSF');
title(sprintf('Diffraction limited, %0.1f mm pupil, %0.f nm',calcPupilMM,calcWavelength));
sliceFig = gcf;
theTolerance = mean(ptbPSF(:))*toleranceFraction;
UnitTest.validationData('ptbPSF', ptbPSF, ...
    'UsingTheFollowingVariableTolerancePairs', ...
    'ptbPSF', theTolerance);

%% Do the same thing using isetbio OI functions
%
% The 'diffraction limited' case generates diffraction limited optics,
% not using zcoeffs.  Because it defaults to parameters for some camera,
% we need to match up human parameters.  Our match here to the wvf struct
% is approximate, as that is based on wvf default for um per degree of 300.
% The approximate is very close as seen in the plot below.
thisWave = 550;
oi = oiCreate('diffraction limited');
optics = oiGet(oi,'optics');
fLength = 0.017;              % Human focal length is about 17 mm
fNumber = 17/calcPupilMM;     % Set f-number which fixes pupil diameter
optics = opticsSet(optics,'flength',fLength);   % Roughly human
optics = opticsSet(optics,'fnumber',fNumber);   % Roughly human
oi = oiSet(oi,'optics',optics);

% Plot the oi version
uData = oiPlot(oi,'psf',[],thisWave);
set(gca,'xlim',[-10 10],'ylim',[-10 10]);

% We have changed the oi structure, so we don't do this validation
% comparison anymore.  But the plot below looks good.
% UnitTest.validationData('oi', oi);

% Pull out slice and add to slice plot
figure(sliceFig); hold on;
[r,c] = size(uData.x);
mid = ceil(r/2);
psfMid = uData.psf(mid,:);
posMM = uData.x(mid,:)/1000;               % Microns to mm
posMinutes = 60*(180/pi)*(atan2(posMM,opticsGet(optics,'flength','mm')));
plot(posMinutes,psfMid/max(psfMid(:)),'ko')
%plot(arcminutes(ptbSampleIndex),ptbPSF(ptbSampleIndex),'b','LineWidth',2);
xlabel('Arc min')
set(gca,'xlim',[-2 2])
grid on
legend('WVF','ISETBIO OI, diff limited','PTB');
UnitTest.validationData('wvf0', wvfGet(wvf0,'psf'));

%% Repeat the PSF calculation with a wavelength offset

% This section checks that if we add an explicit observer defocus correction,
% in this case the amount needed to correct for chromatic aberration, we
% get the same result.  It is a pretty small test of the function
% wvfLCAFromWavelengthDifference relative to the measured wavelength

% Copy the wavefront structure
wvf1 = wvf0;
wvf17 = wvf0;

% Let's work at this very short wavelength
wList = 400;
wvf1 = wvfSet(wvf1,'calc wave',wList);

% This is the chromatic aberration relative to the measured wavelength in
% diopters, and then converted to microns.
lcaDiopters = wvfLCAFromWavelengthDifference(wvfGet(wvf1,'measured wl'),wList);
lcaMicrons = wvfDefocusDioptersToMicrons(...
    lcaDiopters, wvfGet(wvf1,'measured pupil diameter'));

% Add in the lca defocus to the existing defocus term. That happens to be
% zero to start with, but we code for the more general case.
wvf1 = wvfSet(wvf1,'zcoeffs',wvfGet(wvf1,'zcoeffs',{'defocus'})+lcaMicrons,{'defocus'});
wvf1 = wvfCompute(wvf1,'humanlca',true);
w = wvfGet(wvf1,'calc wave');
pupilSize = wvfGet(wvf1,'calc pupil size','mm');

% Get diffraction limited PSF with both measured and calc wavelength set
% the same and to the short wavelength. This should give us the same
% diffraction limited answer at the short wavelength as the other way of
% computing above (and is the more naturally expressive way to get this
% through the wavefront method, if that is all you are trying to do.)
%
% Fuss here with the wvf structure to up spatial sampling density on this
% one so we get a smooth comparison with the others.  The spatial sampling
% in the spatial domain depends on the measurement wavelength, so we don't
% have the psf at exactly the same spatial points here as in the others.
% By upping the density we can look in the plot and see the smooth curve
% pass through the more coarsely computed points.
%
% In the plot created below, the result of this one is the thin green line, which 
% you can examine and see passing through the sample points for the red and blue
% curves, which are more coarser.
wvf17Samples = 1001;
wvf17 = wvfSet(wvf17,'measured wl',wList);
wvf17 = wvfSet(wvf17,'calc wave',wList);
wvf17 = wvfSet(wvf17,'number spatial samples',wvf17Samples);
wvf17 = wvfSet(wvf17,'ref psf sample interval',wvfGet(wvf17,'ref psf sample interval')/4);
wvf17 = wvfCompute(wvf17);

% There should be no difference here between wvf1 and wvf17, because we corrected for the
% chromatic aberration in both cases, once by adding the appropriate defocus explicitly,
% and the other by turning on 'humanlca' for wvfCompute.  The green curve is smoother
% and deviates in between the coarser samples of the red and blue curves,
% but you can see that the function being computed is in good agreement.
[~,h] = wvfPlot(wvf1,'1d psf angle normalized','unit','min','wave',w,'plot range',maxMIN);
set(h,'Color','r','LineWidth',4);
hold on
[~,h] = wvfPlot(wvf17,'1d psf angle normalized','unit','min','wave',w,'plot range',maxMIN,'window',false);
set(h,'Color','g','LineWidth',3);
ptbPSF1 = AiryPattern(radians,pupilSize,w);
plot(arcminutes(ptbSampleIndex),ptbPSF1(ptbSampleIndex),'b','LineWidth',2);
xlabel('Arc Minutes');
ylabel('Normalize PSF');
title(sprintf('Diffraction limited, %0.1f mm pupil, %0.f nm',pupilSize,w));
legend('WVF 1','WVF 17','PTB');

% Save unit test data
UnitTest.validationData('wvf1', wvfGet(wvf1,'psf'));
UnitTest.validationData('wvf17', wvfGet(wvf17,'psf'));
theTolerance = mean(ptbPSF1(:))*toleranceFraction;
UnitTest.validationData('ptbPSF1', ptbPSF1, ...
    'UsingTheFollowingVariableTolerancePairs', ...
    'ptbPSF1', theTolerance);

% PSF angular sampling should be the same across wavelengths
arcminpersample3 = wvfGet(wvf1,'psf angle per sample','min',w);
if (arcminpersample3 ~= arcminpersample)
    error('PSF sampling not constant across wavelengths');
end

%% Use a different pupil size at original wavelength
%
% Copy the original wavefront structure
wvf2  = wvf0;

% Calculate for a larger pupil (less diffraction, therefore.
pupilMM = 7; 
wvf2  = wvfSet(wvf2,'calc pupil diameter',pupilMM);

% Confirm parameters
wvf2 = wvfComputePupilFunction(wvf2);
wvf2 = wvfComputePSF(wvf2);
wvf2  = wvfCompute(wvf2);
wList = wvfGet(wvf2,'calc wave');
pupilSize = wvfGet(wvf2,'calc pupil size','mm');

% Compare the PTB and WVF curves
wvfPlot(wvf2,'1d psf angle normalized','unit','min','wave',wList,'plot range',maxMIN); hold on
ptbPSF2 = AiryPattern(radians,pupilSize,wList);
plot(arcminutes(ptbSampleIndex),ptbPSF2(ptbSampleIndex),'b','LineWidth',2);
xlabel('Arc Minutes');
ylabel('Normalized PSF');
title(sprintf('Diffraction limited, %0.1f mm pupil, %0.f nm',pupilSize,wList));
legend('WFV 2','PTB');

UnitTest.validationData('wvf2', wvfGet(wvf2,'psf'));
theTolerance = mean(ptbPSF2(:))*toleranceFraction;
UnitTest.validationData('ptbPSF2', ptbPSF2, ...
    'UsingTheFollowingVariableTolerancePairs', ...
    'ptbPSF2', theTolerance);

%% Show the PSF slices across wavelengths along with the 'white'
%
% New copy
wvf3 = wvf0;

% This makes a colormap that is like the spectral colors
pupilMM  = 3.0;
thisWave = 420:10:650;
cmap = squeeze(xyz2srgb(XW2RGBFormat(ieReadSpectra('XYZ',thisWave),length(thisWave),1)));

% We compare many wavelengths and the average across them (white)
wvf3 = wvfSet(wvf3,'calc wave',thisWave);
wvf3 = wvfSet(wvf3,'calc pupil diameter',pupilMM);
wvf3 = wvfCompute(wvf3);

vcNewGraphWin;
for ii=1:length(thisWave)
    if ii == 1
        [u,pData] = wvfPlot(wvf3,'1d psf space','unit','um','wave',thisWave(1),'plot range',5*maxMIN,'window',false);
        x = u.x; y = u.y/sum(u.y(:));
        set(pData,'color',cmap(ii,:),'LineWidth',1);
    end
    hold on
    [uData, pData] = wvfPlot(wvf3,'1d psf space','unit','um','wave',thisWave(ii),'window', false);
    thisY = interp1(uData.x,uData.y,x);
    y = y + thisY;
    set(pData,'color',cmap(ii,:),'LineWidth',1);
end
str = num2str(thisWave');

% Calculate the average and plot
y = y/length(thisWave);
p = plot(x,y,'k:'); set(p,'LineWidth',2);
str(end+1,:) = 'wht';

% Labels
xlabel('Position (um)');
ylabel('Slice through PSF');
set(gca,'xlim',[-10 10])
title(sprintf('DL many wavelengths, no LCA, %0.1f mm pupil',wvfGet(wvf3,'calc pupil diameter')));

end


