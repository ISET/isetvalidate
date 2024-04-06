%% Simplifying v_ibioRDT_wvfDiffractionPSF
%
% DHB says there is an issue with padding
%{
Run to line 354 for the call to oiCompute with the PSF method, that
demonstrates the issue as in the first slide of the PowerPoint file I
sent.  Indeed, if you run this script to completion it will produce
the key plot as Figure 2.
 
I spent 5 min tracing down through the oiCompute call.  It does call
oiPadValue as it should.  I think the issue is that the padding size
is based on the assumption that the PSF support is as it was in the
OTF method, that is smaller than in the PSF method.  So the problem
may not be a failure to pad, but a failure to pad with a large enough
border given the increased size of the PSF support. I did not delve
into this deeply enough to be sure, however.
%}

%% Tolerance fraction
toleranceFraction = 0.0002;

% Do diff limited for wvf human oi

% You can set this to false to see human optics rather than
% diffraction limited optics for the wvf human oi case.  Just for
% looking.  It should be true for this validation to work correctly as
% intended.
DIFFLIMITEDOI = true;

%% Get diffraction limited pointspread function using wvf
%
% When the Zernike coefficients are all zero, the wvfCompute code should
% return the diffraction limited PSF.  We test whether this works by
% comparing to the diffraction limited PSF implemented in the PTB routine
% AiryPattern.

% Set up default wvf parameters for the calculation 
wvf0 = wvfCreate;

% Specify the pupil size
calcPupilMM = 3;
wvf0 = wvfSet(wvf0,'calc pupil size',calcPupilMM);

% Plotting ranges for MM, UM, and Minutes of angle
maxMM = 1;
maxUM = 20;
maxMIN = 2;

% Which wavelength to plot
wList = wvfGet(wvf0,'calc wave');

%% Create an ISETBio scene, which we will need below

% We make this a spatial delta function against a uniform background.
% Better style would be to use sets and gets on the photons.
sceneSize = 255;
sceneMiddleRow = floor(sceneSize/2)+1;
pixelsBetweenLines = 5;
bgPhotons = 100;
deltaPhotons = 1000*(sceneSize/256).^2;
deltaWidthPixels = 0;
sceneFov = 1;
scene = sceneCreate('grid lines',sceneSize,pixelsBetweenLines);
scene = sceneSet(scene,'fov',sceneFov);
thePhotons = sceneGet(scene,'photons');
thePhotons = bgPhotons*ones(size(thePhotons));
for ww = 1:size(thePhotons,3)
    thePhotons(sceneMiddleRow-deltaWidthPixels:sceneMiddleRow+deltaWidthPixels,sceneMiddleRow-deltaWidthPixels:sceneMiddleRow+deltaWidthPixels,ww) = deltaPhotons;
end
scene = sceneSet(scene,'photons',thePhotons);
chkPhotons = sceneGet(scene,'photons');
% figure; imagesc(chkPhotons(:,:,16)); axis('square');
% title('Scene photons, wlband index 16');

%% Calculate the PSF
%
% This function computes the PSF by first computing the pupil function.  In
% the default wvf object, the Zernicke coefficients match diffraction.  By
% default, 'humanlca' is false for the wvfCompute function, but we set it
% here for clarity as to what we are doing.
wvf0 = wvfCompute(wvf0,'humanlca',false);

% Grab the psf
psf = wvfGet(wvf0,'psf');

% We make it easy to simply calculate the diffraction-limited psf of the
% current structure this way.  Here we make sure that there is no
% difference. This pretty much has to work, because what the 'diffraction
% psf' get is doing is setting the zcoeffs to zero in a tmp wvf structure
% that is otherwise like the passed one, and otherwise just doing the
% wvfCompute on that structure.
diffpsf = wvfGet(wvf0,'diffraction psf');
UnitTest.assertIsZero(max(abs(psf(:)-diffpsf(:))),'Internal computation of diffraction limited psf',0);

% Verify that the calculated and measured wavelengths are the same.
% This only works because the defaults make it so, so this is really
% just a check that no one messed with the defaults without telling us.
calcWavelength = wvfGet(wvf0,'wavelength');
measWavelength = wvfGet(wvf0,'measured wavelength');
UnitTest.assertIsZero(max(abs(measWavelength(:)-calcWavelength(:))),'Measured and calculation wavelengths compare',0);

%% Plots 
%
% Can make a graph of the PSF over microns within maxUM of center
% wvfPlot(wvf0,'psf','unit','um','wave',wList,'plot range',maxUM);

% Can make a graph of the PSF over minutes within 2 arc min
% wvfPlot(wvf0,'psf angle','unit','min','wave',wList,'plot range',maxMIN);

% Plot the middle row of the psf, unscaled and scaled
%
% This is done by a wvf method.
sliceFig = figure; clf;
set(gcf,'Position',[10 10 2200 750]);
subplot(1,3,1); hold on;
uData_wvfSlice = wvfPlot(wvf0,'1d psf angle','unit','min','wave',wList,'plot range',maxMIN,'window',false);
subplot(1,3,2); hold on;
uData_wvfSlice = wvfPlot(wvf0,'1d psf angle','unit','min','wave',wList,'plot range',maxMIN,'window',false);
subplot(1,3,3); hold on
wvfPlot(wvf0,'1d psf angle normalized','unit','min','wave',wList,'plot range',maxMIN,'window',false);

% Stash wvf0 psf for validation
UnitTest.validationData('wvf0', wvfGet(wvf0,'psf'));

%% Make sure we can convert PSF to OTF and back without generating an error
wvf0_Psf = wvfGet(wvf0,'psf');
[~,~,wvf0_OtfFromPsf] = PsfToOtf([],[],wvf0_Psf);
[~,~,wvf0_PsfFromOtf] = OtfToPsf([],[],wvf0_OtfFromPsf);
if (max(abs(wvf0_Psf(:)-wvf0_PsfFromOtf(:))) > 1e-10)
    error('Cannot use PTF routines to go back and forth between PSF and OTF');
end

% Find location of maximum OTF absolute value.  Should be at center, here
% 101, 101, which it is.
% There is surely a slicker way.
theOtf = wvf0_OtfFromPsf;
maxOtf = -Inf;
for ii = 1:size(theOtf,1)
    for jj = 1:size(theOtf,2)
        if (abs(theOtf(ii,jj)) > maxOtf)
            bestI = ii;
            bestJ = jj;
            maxOtf = abs(theOtf(ii,jj));
        end
    end
end
fprintf('Max of OtfFromPsf at %d, %d\n',bestI,bestJ);

theOtf = wvfGet(wvf0,'otf');
maxOtf = -Inf;
for ii = 1:size(theOtf,1)
    for jj = 1:size(theOtf,2)
        if (abs(theOtf(ii,jj)) > maxOtf)
            bestI = ii;
            bestJ = jj;
            maxOtf = abs(theOtf(ii,jj));
        end
    end
end
fprintf('Max of OtfFromPsf using wvfGet(wvf0,''otf'') at %d, %d\n',bestI,bestJ);

%% Get parameters needed for plotting comparisons below
% 
% This also illustrates some wvfGets
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
ptbSampleIndex = find(abs(arcminutes) < maxMIN);
radians = (pi/180)*(arcminutes/60);

% Compare to what we get from PTB AiryPattern function
% The PTB function returns a normalized Airy pattern, so
% on the left we scale to match the wvf version.
ptbPSF = AiryPattern(radians,calcPupilMM ,calcWavelength);
figure(sliceFig);
subplot(1,3,1); hold on;
plot(arcminutes(ptbSampleIndex),max(uData_wvfSlice.y(:))*ptbPSF(ptbSampleIndex),'b','LineWidth',2);
subplot(1,3,2);
plot(arcminutes(ptbSampleIndex),max(uData_wvfSlice.y(:))*ptbPSF(ptbSampleIndex),'b','LineWidth',2);
subplot(1,3,3);
plot(arcminutes(ptbSampleIndex),ptbPSF(ptbSampleIndex),'b','LineWidth',2);

%% Stash some info for validation
theTolerance = mean(ptbPSF(:))*toleranceFraction;
UnitTest.validationData('ptbPSF', ptbPSF, ...
    'UsingTheFollowingVariableTolerancePairs', ...
    'ptbPSF', theTolerance);

%% Compute diffraction limited PSF for same conditions using OI
%
% We are going to do this several different ways, all of which should give
% the same answer in the end, possibly up to normalization of area under
% PSF.
%
% The 'diffraction limited' OI case generates diffraction limited optics,
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

% Plot the oi diffraction limited version, mainly to get the data.
% Get rid of the close if you want to examine the mesh plot
uData = oiPlot(oi,'psf',[],thisWave);
set(gca,'xlim',[-10 10],'ylim',[-10 10]);
close(gcf);

% Pull out slice and add to slice plot
figure(sliceFig);
[r,c] = size(uData.x);
midRow = ceil(r/2);
psfMidRow = uData.psf(midRow,:);
posRowMM = uData.x(midRow,:)/1000;               % Microns to mm
posRowMinutes = 60*(180/pi)*(atan2(posRowMM,opticsGet(optics,'flength','mm')));
midCol = ceil(c/2);
psfMidCol = uData.psf(:,midCol);
posColMM = uData.y(:,midCol)/1000;               % Microns to mm
posColMinutes = 60*(180/pi)*(atan2(posColMM,opticsGet(optics,'flength','mm')));
figure(sliceFig);
subplot(1,3,1);
plot(arcminutes(ptbSampleIndex),max(uData_wvfSlice.y(:))*ptbPSF(ptbSampleIndex),'b','LineWidth',2);
subplot(1,3,2);
plot(posRowMinutes,psfMidRow,'ko','MarkerFaceColor','k','MarkerSize',14);
figure(sliceFig);
subplot(1,3,3);
plot(posRowMinutes,psfMidRow/max(psfMidRow(:)),'ko','MarkerFaceColor','k','MarkerSize',14);

% Report on sampling and normalization
fprintf('OI DIFF LIMITED\n')
if (posRowMinutes(1) == posColMinutes(1) & posRowMinutes(end) == posColMinutes(end))
    fprintf('\tRow and column range MATCH\n');
else
    fprintf('\tRow and column range DO NOT MATCH\n');
end
if (posRowMinutes(2)-posRowMinutes(1) == posColMinutes(2)-posColMinutes(1))
    fprintf('\tRow and column spacing MATCH\n');
else
    fprintf('\tRow and column spacing DO NOT MATCH\n');
end
if (length(posRowMinutes) == length(posColMinutes))
    fprintf('\tRow and column number of pixels MATCH\n');
else
    fprintf('\tRow and column number of pixels DO NOT MATCH\n');
end
fprintf('\tRow sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posRowMinutes(:)),max(posRowMinutes(:)),posRowMinutes(2)-posRowMinutes(1),length(posRowMinutes));
fprintf('\tCol sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posColMinutes(:)),max(posColMinutes(:)),posColMinutes(2)-posColMinutes(1),length(posColMinutes));
psfIntegratedVol = sum(uData.psf(:))*(posRowMinutes(2)-posRowMinutes(1))*(posColMinutes(2)-posColMinutes(1))*length(posRowMinutes)*length(posColMinutes);
fprintf('\tPSF volume %0.2f (raw sum) %0.2g (integrated)\n',sum(uData.psf(:)),psfIntegratedVol);

%% Let's see if we can get the same answer through the human wvf oi methods.

% First optics psf method on the raw (uncomputed to a scene) oi The
% oiPlot call is executed to get the data.
oi1_psf = oiCreate('human wvf');
wvfForOi = wvfCreate('calc wavelengths',400:10:700);
wvfForOi = wvfCompute(wvfForOi,'humanlca',false);
optics1_psf = wvf2optics(wvfForOi);
if (DIFFLIMITEDOI)
    oi1_psf = oiSet(oi1_psf,'optics',optics1_psf);
end
oi1_psf = oiSet(oi1_psf,'optics name','opticspsf');  
uData1_psf = oiPlot(oi1_psf,'psf',[],thisWave);
title(sprintf('Point spread from modified wvf human (opticspsf) (%d nm)',thisWave));
close(gcf);

% Check that the PSF corresponding to the OTF stored in the oi is
% real.  It would be bad if not.  Note the use of fftshit, to handle
% the difference in ISETBio and PSF conventions about where DC is in
% the OTF.  The routine OtfToPsf will throw an error if the Psf is not
% awfully close to real.
[~,~,psfCheckOptics] = OtfToPsf([],[],fftshift(optics1_psf.OTF.OTF(:,:,1)));
[~,~,psfCheckOi] = OtfToPsf([],[],fftshift(oi1_psf.optics.OTF.OTF(:,:,1)));

% Add to slice plot to compare
[r,c] = size(uData1_psf.x);
midRow = ceil(r/2);
psfMidRow = uData1_psf.psf(midRow,:);
posRowMM = uData1_psf.x(midRow,:)/1000;               % Microns to mm
posRowMinutes = 60*(180/pi)*(atan2(posRowMM,opticsGet(optics1_psf,'flength','mm')));
midCol = ceil(c/2);
psfMidCol = uData1_psf.psf(:,midCol);
posColMM = uData1_psf.y(:,midCol)/1000;               % Microns to mm
posColMinutes = 60*(180/pi)*(atan2(posColMM,opticsGet(optics,'flength','mm')));
figure(sliceFig);
subplot(1,3,1);
plot(posRowMinutes,psfMidRow,'b<','MarkerFaceColor','b','MarkerSize',12);
subplot(1,3,2);
plot(posRowMinutes,psfMidRow,'b<','MarkerFaceColor','b','MarkerSize',12);
subplot(1,3,3);
plot(posRowMinutes,psfMidRow/max(psfMidRow(:)),'b<','MarkerFaceColor','b','MarkerSize',12);

%% Report on sampling and normalization
fprintf('OI PSF RAW\n')
if (posRowMinutes(1) == posColMinutes(1) & posRowMinutes(end) == posColMinutes(end))
    fprintf('\tRow and column range MATCH\n');
else
    fprintf('\tRow and column range DO NOT MATCH\n');
end
if (posRowMinutes(2)-posRowMinutes(1) == posColMinutes(2)-posColMinutes(1))
    fprintf('\tRow and column spacing MATCH\n');
else
    fprintf('\tRow and column spacing DO NOT MATCH\n');
end
if (length(posRowMinutes) == length(posColMinutes))
    fprintf('\tRow and column number of pixels MATCH\n');
else
    fprintf('\tRow and column number of pixels DO NOT MATCH\n');
end
fprintf('\tRow sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posRowMinutes(:)),max(posRowMinutes(:)),posRowMinutes(2)-posRowMinutes(1),length(posRowMinutes));
fprintf('\tCol sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posColMinutes(:)),max(posColMinutes(:)),posColMinutes(2)-posColMinutes(1),length(posColMinutes));
psfIntegratedVol = sum(uData.psf(:))*(posRowMinutes(2)-posRowMinutes(1))*(posColMinutes(2)-posColMinutes(1))*length(posRowMinutes)*length(posColMinutes);
fprintf('\tPSF volume %0.2f (raw sum) %0.2g (integrated)\n',sum(uData.psf(:)),psfIntegratedVol);
theOtf = oi1_psf.optics.OTF.OTF(:,:,1);
maxOtf = -Inf;
for ii = 1:size(theOtf,1)
    for jj = 1:size(theOtf,2)
        if (abs(theOtf(ii,jj)) > maxOtf)
            bestI = ii;
            bestJ = jj;
            maxOtf = abs(theOtf(ii,jj));
        end
    end
end
fprintf('\tMax of OTF at %d, %d\n',bestI,bestJ);

%% Compute on the scene and plot to get the psf data
%
% Section where DHB reports the trouble is identified.  Figure 2 in
% the original script.
%
% The order of key functions called here is
%   oiCompute
%   opticsSICompute
%   opticsPSF
%   oiApplyPSF                   
%
% Sets up a wvf object from the oi, matched to the spatial properties
% of the scene. Computes PSF from the new wvf object, converts to OTF,
% stores this in the oi, and convolves in the frequency domain. The
% convolution is done with routine ImageConvFrequencyDomain
%
% The red points in this figure
oi2_psf = oiCompute(oi1_psf,scene,'pad value','mean');
uData2_psf = oiPlot(oi2_psf,'psf',[],thisWave);
title(sprintf('Point spread from modified wvf human after compute (%d nm)',thisWave));
close(gcf);

% Plot a slice of the computed oi photons
theWl = 550;
wls = oiGet(oi2_psf,'wave');
wlIndex = find(wls == theWl);
oiSliceFigure = figure; clf; 
set(gcf,'Position',[100 100 2200 750]);
oiPhotons2_psf = oiGet(oi2_psf,'photons');
oiPositions2_psf = 60*oiGet(oi2_psf,'angular support');
oiNumberRows_psf = size(oiPhotons2_psf,1);
oiMiddleRow_psf = floor(oiNumberRows_psf/2) + 1;
subplot(1,3,1); hold on;
plot(oiPositions2_psf(oiMiddleRow_psf,:,1),oiPhotons2_psf(oiMiddleRow_psf,:,wlIndex),'r','LineWidth',1);
plot(oiPositions2_psf(oiMiddleRow_psf,:,1),oiPhotons2_psf(oiMiddleRow_psf,:,wlIndex),'ro','MarkerFaceColor','r','MarkerSize',11);
subplot(1,3,2); hold on
plot(oiPositions2_psf(oiMiddleRow_psf,:,1),oiPhotons2_psf(oiMiddleRow_psf,:,wlIndex),'r','LineWidth',1);
plot(oiPositions2_psf(oiMiddleRow_psf,:,1),oiPhotons2_psf(oiMiddleRow_psf,:,wlIndex),'ro','MarkerFaceColor','r','MarkerSize',11);
subplot(1,3,3); hold on;
plot(oiPositions2_psf(oiMiddleRow_psf,:,1),oiPhotons2_psf(oiMiddleRow_psf,:,wlIndex),'r','LineWidth',1);
plot(oiPositions2_psf(oiMiddleRow_psf,:,1),oiPhotons2_psf(oiMiddleRow_psf,:,wlIndex),'ro','MarkerFaceColor','r','MarkerSize',11);
% figure; imagesc(oiPhotons2_psf(:,:,16)); axis('square');
% title('PSF method photons in OI wlband index 16');
%{
% Add to slice plot to compare
[r,c] = size(uData2_psf.x);
midRow = ceil(r/2);
psfMidRow = uData2_psf.psf(midRow,:);
posRowMM = uData2_psf.x(midRow,:)/1000;               % Microns to mm
posRowMinutes = 60*(180/pi)*(atan2(posRowMM,opticsGet(optics1_psf,'flength','mm')));
midCol = ceil(c/2);
psfMidCol = uData2_psf.psf(:,midCol);
posColMM = uData2_psf.y(:,midCol)/1000;               % Microns to mm
posColMinutes = 60*(180/pi)*(atan2(posColMM,opticsGet(optics,'flength','mm')));
figure(sliceFig);
subplot(1,3,1);
plot(posRowMinutes,psfMidRow,'r>','MarkerFaceColor','r','MarkerSize',11);
subplot(1,3,2);
plot(posRowMinutes,psfMidRow,'r>','MarkerFaceColor','r','MarkerSize',11);
subplot(1,3,3);
plot(posRowMinutes,psfMidRow/max(psfMidRow(:)),'r>','MarkerFaceColor','r','MarkerSize',11);
%}
%{
%% Report on sampling and normalization
fprintf('OI PSF COMPUTE\n')
if (posRowMinutes(1) == posColMinutes(1) & posRowMinutes(end) == posColMinutes(end))
    fprintf('\tRow and column range MATCH\n');
else
    fprintf('\tRow and column range DO NOT MATCH\n');
end
if (posRowMinutes(2)-posRowMinutes(1) == posColMinutes(2)-posColMinutes(1))
    fprintf('\tRow and column spacing MATCH\n');
else
    fprintf('\tRow and column spacing DO NOT MATCH\n');
end
if (length(posRowMinutes) == length(posColMinutes))
    fprintf('\tRow and column number of pixels MATCH\n');
else
    fprintf('\tRow and column number of pixels DO NOT MATCH\n');
end
fprintf('\tRow sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posRowMinutes(:)),max(posRowMinutes(:)),posRowMinutes(2)-posRowMinutes(1),length(posRowMinutes));
fprintf('\tCol sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posColMinutes(:)),max(posColMinutes(:)),posColMinutes(2)-posColMinutes(1),length(posColMinutes));
psfIntegratedVol = sum(uData.psf(:))*(posRowMinutes(2)-posRowMinutes(1))*(posColMinutes(2)-posColMinutes(1))*length(posRowMinutes)*length(posColMinutes);
fprintf('\tPSF volume %0.2f (raw sum) %0.2g (integrated)\n',sum(uData.psf(:)),psfIntegratedVol);

%% Then the optics otf method
%
% This was the method used in ISETBio prior to the merge with ISETCam.
oi1_otf = oiCreate('human wvf');
optics1_otf = optics1_psf;
if (DIFFLIMITEDOI)
    oi1_otf = oiSet(oi1_otf,'optics',optics1_otf );
end
oi1_otf = oiSet(oi1_otf,'optics name','opticsotf');  
uData1_otf = oiPlot(oi1_otf,'psf',[],thisWave);
title(sprintf('Point spread from modified wvf human (opticspsf) (%d nm)',thisWave));
close(gcf);

% Add to slice plot to compare
[r,c] = size(uData1_otf.x);
midRow = ceil(r/2);
psfMidRow = uData1_otf.psf(midRow,:);
posRowMM = uData1_otf.x(midRow,:)/1000;               % Microns to mm
posRowMinutes = 60*(180/pi)*(atan2(posRowMM,opticsGet(optics1_otf,'flength','mm')));
midCol = ceil(c/2);
psfMidCol = uData1_otf.psf(:,midCol);
posColMM = uData1_otf.y(:,midCol)/1000;               % Microns to mm
posColMinutes = 60*(180/pi)*(atan2(posColMM,opticsGet(optics,'flength','mm')));
figure(sliceFig);
subplot(1,3,1);
plot(posRowMinutes,psfMidRow,'ys','MarkerFaceColor','y','MarkerSize',8);
subplot(1,3,2); hold on;
plot(posRowMinutes,psfMidRow,'ys','MarkerFaceColor','y','MarkerSize',8);
subplot(1,3,3); hold on;
plot(posRowMinutes,psfMidRow/max(psfMidRow(:)),'ys','MarkerFaceColor','y','MarkerSize',8);

% Report on sampling an normalization
fprintf('OI OTF RAW\n')
if (posRowMinutes(1) == posColMinutes(1) & posRowMinutes(end) == posColMinutes(end))
    fprintf('\tRow and column range MATCH\n');
else
    fprintf('\tRow and column range DO NOT MATCH\n');
end
if (posRowMinutes(2)-posRowMinutes(1) == posColMinutes(2)-posColMinutes(1))
    fprintf('\tRow and column spacing MATCH\n');
else
    fprintf('\tRow and column spacing DO NOT MATCH\n');
end
if (length(posRowMinutes) == length(posColMinutes))
    fprintf('\tRow and column number of pixels MATCH\n');
else
    fprintf('\tRow and column number of pixels DO NOT MATCH\n');
end
fprintf('\tRow sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posRowMinutes(:)),max(posRowMinutes(:)),posRowMinutes(2)-posRowMinutes(1),length(posRowMinutes));
fprintf('\tCol sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posColMinutes(:)),max(posColMinutes(:)),posColMinutes(2)-posColMinutes(1),length(posColMinutes));
psfIntegratedVol = sum(uData.psf(:))*(posRowMinutes(2)-posRowMinutes(1))*(posColMinutes(2)-posColMinutes(1))*length(posRowMinutes)*length(posColMinutes);
fprintf('\tPSF volume %0.2f (raw sum) %0.2g (integrated)\n',sum(uData.psf(:)),psfIntegratedVol);
theOtf = oi1_otf.optics.OTF.OTF(:,:,1);
maxOtf = -Inf;
for ii = 1:size(theOtf,1)
    for jj = 1:size(theOtf,2)
        if (abs(theOtf(ii,jj)) > maxOtf)
            bestI = ii;
            bestJ = jj;
            maxOtf = abs(theOtf(ii,jj));
        end
    end
end
fprintf('\tMax of OTF at %d, %d\n',bestI,bestJ);

% And now after oi compute on the scene
%
% The order of key functions called here is
%   oiCompute
%   opticsSICompute                Sets the angular size of the oi tomatch the scene.  This, I think, makes the frequency support of the oi
%                                  different from what is stored in the optics structure, where the OTF lives.
%   opticsOTF
%   opticCalculateOTF              Computes the frequency support of the oi and calls customOTF to interpolate the OTF to that support.
%   customOTF                      Interpolates the OTF stored in the oi to the frequency sampling passed. 
oi2_otf = oiCompute(oi1_otf,scene,'pad value','mean');
figure(oiSliceFigure);
oiPhotons2_otf = oiGet(oi2_otf,'photons');
oiPositions2_otf = 60*oiGet(oi2_otf,'angular support');
oiNumberRows_otf = size(oiPhotons2_otf,1);
oiMiddleRow_otf = floor(oiNumberRows_otf/2) + 1;
subplot(1,3,1);
plot(oiPositions2_otf(oiMiddleRow_otf,:,1),oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex),'g','LineWidth',1);
plot(oiPositions2_otf(oiMiddleRow_otf,:,1),oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Position (min)');
ylabel('Photons');
title({'OI comparison, spatial delta funciton input, full image' ; sprintf('Scene fov %0.1f degs; scene pixels %d, bgPhotons %d, deltaPhotons %d',sceneFov,sceneSize,bgPhotons,deltaPhotons)});
legend('PSF method', '', 'OTF method', '');
subplot(1,3,2);
plot(oiPositions2_otf(oiMiddleRow_otf,:,1),oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex),'g','LineWidth',1);
plot(oiPositions2_otf(oiMiddleRow_otf,:,1),oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Position (min)');
ylabel('Photons');
title({'OI comparison, spatial delta funciton input, central portion, full intensity range' ; sprintf('Scene fov %0.1f degs; scene pixels %d, bgPhotons %d, deltaPhotons %d',sceneFov,sceneSize,bgPhotons,deltaPhotons)});
xlim([-10*maxMIN 10*maxMIN]);
ylim([ 0 1.5*max([oiPhotons2_otf(oiMiddleRow_psf,:,wlIndex) oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex)]) ]);
legend('PSF method', '', 'OTF method', '');
subplot(1,3,3);
plot(oiPositions2_otf(oiMiddleRow_otf,:,1),oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex),'g','LineWidth',1);
plot(oiPositions2_otf(oiMiddleRow_otf,:,1),oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex),'go','MarkerFaceColor','g','MarkerSize',8);
xlabel('Position (min)');
ylabel('Photons');
title({'OI comparison, spatial delta funciton input, central portion, expanded intensity range' ; sprintf('Scene fov %0.1f degs; scene pixels %d, bgPhotons %d, deltaPhotons %d',sceneFov,sceneSize,bgPhotons,deltaPhotons)});
xlim([-2*maxMIN 2*maxMIN]);
ylim([ 0.9*min([oiPhotons2_otf(oiMiddleRow_psf,:,wlIndex) oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex)]) ...
    min([oiPhotons2_otf(oiMiddleRow_psf,:,wlIndex) oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex)]) + 0.2*(max([oiPhotons2_otf(oiMiddleRow_psf,:,wlIndex) oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex)]) - min([oiPhotons2_otf(oiMiddleRow_psf,:,wlIndex) oiPhotons2_otf(oiMiddleRow_otf,:,wlIndex)]))]);
legend('PSF method', '', 'OTF method', '');
% figure; imagesc(oiPhotons2_otf(:,:,16)); axis('square');
% title('MTF method photons in OI, wlband index 16');

% Plot to get data
uData2_otf = oiPlot(oi2_otf,'psf',[],thisWave);
title(sprintf('Point spread from modified wvf human after compute (%d nm)',thisWave));
close(gcf);

% Add to slice plot to compare
[r,c] = size(uData2_otf.x);
midRow = ceil(r/2);
psfMidRow = uData2_otf.psf(midRow,:);
posRowMM = uData2_otf.x(midRow,:)/1000;               % Microns to mm
posRowMinutes = 60*(180/pi)*(atan2(posRowMM,opticsGet(optics1_psf,'flength','mm')));
midCol = ceil(c/2);
psfMidCol = uData2_otf.psf(:,midCol);
posColMM = uData2_otf.y(:,midCol)/1000;               % Microns to mm
posColMinutes = 60*(180/pi)*(atan2(posColMM,opticsGet(optics,'flength','mm')));
figure(sliceFig);
subplot(1,3,1);
plot(posRowMinutes,psfMidRow,'gs','MarkerFaceColor','g','MarkerSize',6);
subplot(1,3,2);
plot(posRowMinutes,psfMidRow,'gs','MarkerFaceColor','g','MarkerSize',6);
subplot(1,3,3);
plot(posRowMinutes,psfMidRow/max(psfMidRow(:)),'gs','MarkerFaceColor','g','MarkerSize',6);

% Report on sampling an normalization
fprintf('OI OTF COMPUTE\n')
if (posRowMinutes(1) == posColMinutes(1) & posRowMinutes(end) == posColMinutes(end))
    fprintf('\tRow and column range MATCH\n');
else
    fprintf('\tRow and column range DO NOT MATCH\n');
end
if (posRowMinutes(2)-posRowMinutes(1) == posColMinutes(2)-posColMinutes(1))
    fprintf('\tRow and column spacing MATCH\n');
else
    fprintf('\tRow and column spacing DO NOT MATCH\n');
end
if (length(posRowMinutes) == length(posColMinutes))
    fprintf('\tRow and column number of pixels MATCH\n');
else
    fprintf('\tRow and column number of pixels DO NOT MATCH\n');
end
fprintf('\tRow sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posRowMinutes(:)),max(posRowMinutes(:)),posRowMinutes(2)-posRowMinutes(1),length(posRowMinutes));
fprintf('\tCol sampling min, max, spacing (min): %0.2f, %0.2f, %0.4f, %d samples\n',min(posColMinutes(:)),max(posColMinutes(:)),posColMinutes(2)-posColMinutes(1),length(posColMinutes));
psfIntegratedVol = sum(uData.psf(:))*(posRowMinutes(2)-posRowMinutes(1))*(posColMinutes(2)-posColMinutes(1))*length(posRowMinutes)*length(posColMinutes);
fprintf('\tPSF volume %0.2f (raw sum) %0.2g (integrated)\n',sum(uData.psf(:)),psfIntegratedVol);

%% Tidy up slice figure
figure(sliceFig);
subplot(1,3,1);
grid on;
xlabel('Arc Minutes');
ylabel('PSF');
title({sprintf('Diffraction limited, %0.1f mm pupil, %0.f nm',calcPupilMM,calcWavelength) ; sprintf('Scene fov %0.1f degs; scene pixels %d, bgPhotons %d, deltaPhotons %d',sceneFov,sceneSize,bgPhotons,deltaPhotons)});
legend({'WVF','PTB AIRY SCALED TO WVF','OI DIFF LIMITED','OI PSF RAW','OI PSF COMPUTE','OI OTF RAW','OI OTF COMPUTE'});
subplot(1,3,2);
set(gca,'xlim',[-2 2]);
grid on;
xlabel('Arc Minutes');
ylabel('PSF');
title({sprintf('Diffraction limited, %0.1f mm pupil, %0.f nm',calcPupilMM,calcWavelength) ; sprintf('Scene fov %0.1f degs; scene pixels %d, bgPhotons %d, deltaPhotons %d',sceneFov,sceneSize,bgPhotons,deltaPhotons)});
legend({'WVF','PTB AIRY SCALED TO WVF','OI DIFF LIMITED','OI PSF RAW','OI PSF COMPUTE','OI OTF RAW','OI OTF COMPUTE'});
subplot(1,3,3);
set(gca,'xlim',[-2 2]);
grid on;
xlabel('Arc Minutes');
ylabel('Normalized PSF');
title({sprintf('Diffraction limited, %0.1f mm pupil, %0.f nm',calcPupilMM,calcWavelength) ; sprintf('Scene fov %0.1f degs; scene pixels %d, bgPhotons %d, deltaPhotons %d',sceneFov,sceneSize,bgPhotons,deltaPhotons)});
legend({'WVF','PTB AIRY','OI DIFF LIMITED','OI PSF RAW','OI PSF COMPUTE','OI OTF RAW','OI OTF COMPUTE'});

%% Repeat the PSF calculation with a wavelength offset
%
% This section checks that if we add an explicit observer defocus correction,
% in this case the amount needed to correct for chromatic aberration, we
% get the same result as when we compute asking for 'humanlca'.  It is a pretty
% small test of the function wvfLCAFromWavelengthDifference relative to the measured
% wavelength, as well as that we still understand how to control the wvf
% calculations after the move to isetcam.
%
% Copy the wavefront structures
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

% Add the lca defocus to the existing defocus term. That happens to be
% zero to start with, but we code for the more general case.  Doing
% this offsets the LCA that gets added in with 'humanlca' at true as
% in the wvfCompute just below, so we end up at diffraction limited for 
% the calculated wavelength.
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
% you can examine and see passing through the sample points for the blue and red 
% curves, which are coarser.
wvf17Samples = 1001;
wvf17 = wvfSet(wvf17,'measured wl',wList);
wvf17 = wvfSet(wvf17,'calc wave',wList);
wvf17 = wvfSet(wvf17,'number spatial samples',wvf17Samples);
wvf17 = wvfSet(wvf17,'ref psf sample interval',wvfGet(wvf17,'ref psf sample interval')/4);
wvf17 = wvfCompute(wvf17,'humanlca',true);

% There should be no difference here between wvf1 and wvf17, because we corrected for the
% chromatic aberration in both cases, once by adding the appropriate defocus explicitly,
% and the other by turning on 'humanlca' for wvfCompute.  The green curve is smoother
% and deviates in between the coarser samples of the red and blue curves,
% but you can see that the function being computed is in good agreement.
[~,h] = wvfPlot(wvf1,'1d psf angle normalized','unit','min','wave',w,'plot range',maxMIN);
set(h,'Color','r','LineWidth',4);
hold on
[~,h] = wvfPlot(wvf17,'1d psf angle normalized','unit','min','wave',w,'plot range',maxMIN,'window',false);
%[~,h] = wvfPlot(wvf17,'1d psf angle','unit','min','wave',w,'plot range',maxMIN,'window',false);
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
%}
%% END

