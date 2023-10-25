function varargout = v_ibio_cmCurrentImpulse(varargin)
%
% Cone mosaic photocurrent impulse response calculations.
%
% We will systematically change parameters and see that the results are stable.
%
% BW, ISETBIO Team Copyright 2016

varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);

end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)

%% Show the impulse response
%
% The impulse is a flash on a steady background.  You can set the steady
% background and the duration of and such here.
%
% 

%% Initialize
% ieInit;
runTimeParams.generatePlots = true;

%% Reproduce identical random numbers
rng('default'); rng(3);

%% Set testing tolerance
toleranceFraction = 3e-4;

%% Impulse on a 5 ms time axis.
integrationTime = 5e-3;
nTemporalSamples = 25;
sampleTimes = (1:nTemporalSamples)*integrationTime;
modulation = zeros(nTemporalSamples,1);
modulation(10:11) = 1;

%% Scene parameters in general
sceneParams.fov       = 0.5;   % Half a degree

% 100 is the default, and because oisCreate calls a set that doesn't
% really do anything, the fact that this was set to 50 in the ISETBio
% validation was not doing much.
sceneParams.meanluminance = 100;    % Uniform scene luminance (cd/m2)

% Creates the impulse.  Steady background of 50 cd/m2, then a flash at
% 100 cd/m2 for 5 ms, then back to 50.
oiImpulse = oisCreate('impulse','add',modulation,...
    'sceneParameters',sceneParams,...
    'sampleTimes',sampleTimes);

%% Set the cone mosaic parameters
cMosaic = coneMosaicRect;           % Default is osLinear
cMosaic.noiseFlag = 'none';     % Turn off photon noise
cMosaic.os.noiseFlag = 'none';  % Turn off photocurrent noise
cMosaic.integrationTime = integrationTime;
cMosaic.setSizeToFOV(oiGet(oiImpulse.oiFixed,'fov')*0.8);
cMosaic.emPositions = zeros(nTemporalSamples,2);

%% Compute the absorptions and their sum
%
% Compare to previously generated values with fractional tolerance.
cMosaic.compute(oiImpulse);

%% Compute the current and get the interpolated filters
%
% No noise, compute the filters
cMosaic.os.noiseFlag = 'none';
interpFilters = cMosaic.computeCurrent;

%% Save validation data
absorptions = cMosaic.absorptions;
photocurrents = cMosaic.current;

theTolerance = mean(absorptions(:))*toleranceFraction;
UnitTest.validationData('absorptions', absorptions, ...
    'UsingTheFollowingVariableTolerancePairs', ...
    'absorptions', theTolerance);

theTolerance = mean(abs(photocurrents(:)))*toleranceFraction;
UnitTest.validationData('photocurrents', photocurrents, ...
    'UsingTheFollowingVariableTolerancePairs', ...
    'photocurrents', theTolerance);

theTolerance = mean(abs(interpFilters(:)))*toleranceFraction;
UnitTest.validationData('interpFilters', interpFilters, ...
    'UsingTheFollowingVariableTolerancePairs', ...
    'interpFilters', theTolerance);

%% Visually compare the interpolated and complete impulse response functions.
if (runTimeParams.generatePlots)
    cMosaic.plot('os impulse response');
    hold on;
    plot(cMosaic.interpFilterTimeAxis, interpFilters,'o');
    grid on; xlabel('Time (sec)');
end

end
