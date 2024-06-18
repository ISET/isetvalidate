%% Validate the iset fundamental figures
%
%

if isempty(which('iefundamentalsRootPath'))
    warning('isetfundamentals not on your path');
    return;
end

%%
ieInit;

%%
fig01MaxwellCMF2CIE;
drawnow;

%%
s_cfIntersectingPlanes
drawnow;

%%
fig03WDWStockman
drawnow;

%%
fig04ConeEstimates
drawnow;

%%
fig05VirtualChannels
drawnow;
