% v_iset3d_assets
%
% Check that we can merge the pre-computed assets into a simple
% scene, in this case the Cornell Box
%
% See also
%   s_assetsRecipe, piAssetLoad, piRecipeMerge, piDirGet

%{
Failed as of Jan 25, 2024.
head.mat
mccCB.mat
plane.mat
%}

%% Initialize ISETCam and ISET3d-V4
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Render each asset using the Cornell box scene as the base scene
  
parentRecipe = piRecipeDefault('scene name','cornell_box');
lightName = 'from camera';
ourLight = piLightCreate(lightName,...
    'type','distant');
recipeSet(parentRecipe,'lights', ourLight,'add');
% piWRS(parentRecipe);

%% The pre-computed assets

assetFiles = dir([fullfile(piDirGet('assets'),filesep(),'*.mat')]);
fprintf('Found %d assets\n',numel(assetFiles));
for ii=1:numel(assetFiles)
    fprintf('%d %s\n',ii,assetFiles(ii).name);
end

%% Loop over each asset

% Return a report
report = '';
status = false(1,numel(assetFiles));
for ii = 1:numel(assetFiles)

    % I think we need to reload to avoid issues
    % from previous runs
    parentRecipe = piRecipeDefault('scene name','cornell_box');
    lightName = 'from camera';
    ourLight = piLightCreate(lightName,'type','distant');
    
    recipeSet(parentRecipe,'lights', ourLight,'add');
    assetName = assetFiles(ii).name;
    fprintf('\n\nTesting: %s\n_________\n',assetName);
    
    try
        % Load the asset
        ourAsset  = piAssetLoad(assetName);

        % Scale its size to be good for the Cornell Box
        thisID = ourAsset.thisR.get('objects');   % Object id
        sz = ourAsset.thisR.get('asset',thisID(1),'size');
        ourAsset.thisR.set('asset',thisID(1),'scale',[0.1 0.1 0.1] ./ sz);
        
        % Merge it with the Cornell Box
        combinedR = piRecipeMerge(parentRecipe, ourAsset.thisR);
        % piAssetGeometry(combinedR);
        
        combinedR.show('textures');
        
        % Render it
        piWRS(combinedR);
        
        status(ii) = true;
        report = [report sprintf("Asset: %s Succeeded.\n", assetName)]; %#ok<AGROW>
    catch
        % If it failed, we report that.
        % dockerWrapper.reset;
        status(ii) = false;
        report = [report sprintf("Asset: %s failed \n", assetName)]; %#ok<AGROW>
    end

end

%%
fprintf("Asset Validation Results: \n");
assetNames = cell(size(assetFiles));
for ii=1:numel(assetFiles), assetNames{ii} = assetFiles(ii).name; end

cprintf('Green','Succeeded\n')
tmp = assetNames(status);
for ii=1:numel(tmp)
    fprintf('%s\n',tmp{ii});
end

cprintf('Red','\nFailed\n')
tmp = assetNames(~status);
for ii=1:numel(tmp)
    fprintf('%s\n',tmp{ii});
end

%%
assert(isempty(tmp));

%%