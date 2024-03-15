function varargout = v_ibioRDT_oi(varargin)
%
% Test optical image creating functions
%
% Implicitly tests the opticsCreate functions, as well.
%
% Copyright Imageval LLC, 2009

% History:
%    08/31/23  dhb  This was passing but storing full structures.  I
%                   changed to do more computes and save the photons.  This will
%                   generalize better.

    varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
    
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)

    %% Initialize ISETBIO
    % ieInit;
    close all;
    runTimeParams.generatePlots = true;

    % Tolerance fraction
    toleranceFraction = 0.0001;

    % Create a scene to check oi function
    patchSize = 64;
    sceneFov = 1;
    scene = sceneCreate('macbeth d65',patchSize);
    scene = sceneSet(scene,'fov',sceneFov);
    theScenePhotons = sceneGet(scene,'photons');
    theTolerance = mean(theScenePhotons(:))*toleranceFraction;
    UnitTest.validationData('theScenePhotons',theScenePhotons, ...
        'UsingTheFollowingVariableTolerancePairs', ...
        'theScenePhotons', theTolerance);

    %% Diffraction limited simulation properties
    % 
    % This fails because (probably) because the oiCreate for diffraction
    % limited does not include the human lens in the ISETBio/ISETCam
    % configuration.
    %
    % oi = oiCompute(oi,scene, %pad value ,{‘zero’,’mean’,’border’}, ’crop’,true/false);
    oi = oiCreate('diffraction limited');
    oi = oiCompute(oi,scene,'pad value','mean');
    if (runTimeParams.generatePlots)
        oiPlot(oi,'otf',[],550); 
        oiPlot(oi,'otf',[],450); 
    end
    theOiPhotons = oiGet(oi,'photons');

    % December, 2023. After wvfGet change.
    % assert(abs((mean(theOiPhotons(:))/1.7930e+14) - 1) < 1e-3);
    % assert(abs(oiGet(oi,'wAngular') - 12.4822) < 1e-4);
    % assert(abs(oiGet(oi,'optics focal length') - 0.0039) < 1e-4);
    theTolerance = mean(theOiPhotons(:))*toleranceFraction;
    UnitTest.validationData('diffractionLimitedFromScenePhotons', theOiPhotons, ...
        'UsingTheFollowingVariableTolerancePairs', ...
        'diffractionLimitedFromScenePhotons', theTolerance);    

    %% Wavefront (Thibos) human optics
    % 
    % 'opticsotf' method is the original ISETBio method
    oi = oiCreate('wvf human');
    oi = oiSet(oi,'optics name','opticsotf');  
    oi = oiCompute(oi,scene,'pad value','mean');
    if (runTimeParams.generatePlots)
        uData420 = oiPlot(oi,'psf',[],420); xlim([-60 60]); ylim([-60 60]); zlim([0 5e-4]);
        title('OpticsOtf Method 420 nm')
        uData550 = oiPlot(oi,'psf',[],550); xlim([-60 60]); ylim([-60 60]); zlim([0 5e-2]);
        title('OpticsOtf Method 550 nm')
    end
    theOiPhotons = oiGet(oi,'photons');
    mean(theOiPhotons(:))
    max(theOiPhotons(:))

    % Repeat with new PSF method
    %
    % This is the new method in isetcam.  The psf
    % is undersampled and LCA does not seem to be
    % turned on.
    oi1 = oiCreate('wvf human');
    oi1 = oiSet(oi1,'optics name','opticspsf');  
    oi1 = oiCompute(oi1,scene,'pad value','mean');
    if (runTimeParams.generatePlots)
        uData4201 = oiPlot(oi1,'psf',[],420); xlim([-60 60]); ylim([-60 60]); zlim([0 5e-4]);
        title('OpticsPsf Method 420 nm')
        uData5501 = oiPlot(oi1,'psf',[],550); xlim([-60 60]); ylim([-60 60]);  zlim([0 5e-2]);
        title('OpticsPsf Method 550 nm')
    end
    theOiPhotons1 = oiGet(oi1,'photons');
    mean(theOiPhotons1(:))
    max(theOiPhotons1(:))

    % The PSFs should all sum to 1, which they do
    if (abs(sum(uData420.psf(:))-1) > 1e-6)
        error('420 nm PSF from OTF method does not sum to 1');
    end
    if (abs(sum(uData4201.psf(:))-1) > 1e-6)
        error('420 nm PSF from PSF method does not sum to 1');
    end
    if (abs(sum(uData550.psf(:))-1) > 1e-6)
        error('550 nm PSF from OTF method does not sum to 1');
    end
    if (abs(sum(uData5501.psf(:))-1) > 1e-6)
        error('550 nm PSF from PSF method does not sum to 1');
    end

    % Check volume in new psf over same range as old psf.
    maxOpticsOtfMethodSupport = max([uData420.x(:) ; uData420.y(:)]);
    index = find(uData4201.x(:) <= maxOpticsOtfMethodSupport & uData4201.y(:) <= maxOpticsOtfMethodSupport);
    sum(uData4201.psf(index))
    sum(uData5501.psf(index))

    % Compare slice of PSF for two methods
    index = find(uData420.y == min(abs(uData420.y(:))));
    index1 = find(uData4201.y == min(abs(uData4201.y(:))));
    figure; clf; set(gcf,'Position',[100 100 1500 600]);
    subplot(1,2,1); hold on;
    plot(uData420.x(index),uData420.psf(index),'r','LineWidth',2);
    plot(uData4201.x(index1),uData4201.psf(index1),'b','LineWidth',2);
    scaleFactor = max(uData4201.psf(index1))/max(uData420.psf(index));
    plot(uData420.x(index),scaleFactor*uData420.psf(index),'r:','LineWidth',1);
    xlabel('x position'); ylabel('psf');
    legend({'Original OTF method','New PSF method','Scaled original OTF method'});
    title('420 nm');

    subplot(1,2,2); hold on;
    plot(uData550.x(index),uData550.psf(index),'r');
    plot(uData5501.x(index1),uData5501.psf(index1),'b');
    scaleFactor = max(uData5501.psf(index1))/max(uData550.psf(index));
    plot(uData550.x(index),scaleFactor*uData550.psf(index),'r:','LineWidth',1);
    xlabel('x position'); ylabel('psf');
    legend({'Original OTF method','New PSF method'});
    title('550 nm');

    % December, 2023. After wvfGet change.
    % assert(abs( mean(theOiPhotons(:))/6.9956e+13 - 1) < 1e-4);
    % abs(mean(theOiPhotons(:))/6.9956e+13 - 1)
    % abs(mean(theOiPhotons1(:))/6.9956e+13 - 1)
    
    theTolerance = mean(theOiPhotons(:))*toleranceFraction;
    UnitTest.validationData('humanWVFFromScenePhotons', theOiPhotons, ...
        'UsingTheFollowingVariableTolerancePairs', ...
        'humanWVFFromScenePhotons', theTolerance);    

    %% A simple case used for testing
    oi = oiCreate('uniform ee');

    % The oi is created in a special way.  This might change, and if so we
    % might have to change this test.
    assert(abs(oiGet(oi,'optics fNumber')/1e-3 - 1) < 1e-3);

    % With the new oi compute, we have slight differences at the edge.
    oi = oiCompute(oi,scene,'pad value','mean');
    if (runTimeParams.generatePlots)
        oiPlot(oi,'psf',[],420);
        oiPlot(oi,'psf',[],550);
    end
    theOiPhotons = oiGet(oi,'photons');
    theTolerance = mean(theOiPhotons(:))*toleranceFraction;
    UnitTest.validationData('unifromEEFromScenePhotons', theOiPhotons, ...
        'UsingTheFollowingVariableTolerancePairs', ...
        'unifromEEFromScenePhotons', theTolerance);    

    %% Make a scene and show some oiGets and oiCompute work
    oi = oiCreate('humanmw');
    oi = oiCompute(oi,scene,'pad value','mean');
    if (runTimeParams.generatePlots)
        oiPlot(oi,'illuminance mesh linear');
    end
    theOiPhotons = oiGet(oi,'photons');
    theTolerance = mean(theOiPhotons(:))*toleranceFraction;
    UnitTest.validationData('humanMWOIFromScenePhotons', theOiPhotons, ...
        'UsingTheFollowingVariableTolerancePairs', ...
        'humanMWOIFromScenePhotons', theTolerance);    

    %% Check GUI control
    if (runTimeParams.generatePlots)
        vcAddAndSelectObject(oi);
        oiWindow;
        oiSet([],'gamma',1);
    end

end