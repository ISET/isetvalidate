function varargout = v_ibio_oi(varargin)
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

    % Tolerance fraction
    toleranceFraction = 0.0001;

    % Create a scene to check oi function
    scene = sceneCreate;
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
    assert(abs((mean(theOiPhotons(:))/1.7930e+14) - 1) < 1e-3);
    assert(abs(oiGet(oi,'wAngular') - 12.4822) < 1e-4);
    assert(abs(oiGet(oi,'optics focal length') - 0.0039) < 1e-4);

    theTolerance = mean(theOiPhotons(:))*toleranceFraction;
    UnitTest.validationData('diffractionLimitedFromScenePhotons', theOiPhotons, ...
        'UsingTheFollowingVariableTolerancePairs', ...
        'diffractionLimitedFromScenePhotons', theTolerance);    

    %% Wavefront (Thibos) human optics
    oi = oiCreate('wvf human');
    %oi = oiSet(oi,'focal length',)
    oi = oiCompute(oi,scene,'pad value','mean');
    if (runTimeParams.generatePlots)
        oiPlot(oi,'psf',[],420);
        oiPlot(oi,'psf',[],550);
    end
    theOiPhotons = oiGet(oi,'photons');
    
    % December, 2023. After wvfGet change.
    assert(abs( mean(theOiPhotons(:))/6.9956e+13 - 1) < 1e-4);
    
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