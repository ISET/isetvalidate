% A validation script that runs through all of the preset materials
%
% We change the material on the bunny set against a bright background,
% which lets us judge transparency.
%
% See also
%  

%% Starting code from the MaterialInsert test:
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Load the bunny scene
thisR = piRecipeDefault('scene name','bunny');
bunnyID = piAssetSearch(thisR,'object name','Bunny');

% Add the skymap
thisR.set('skymap','room.exr');
thisR.set('asset',bunnyID,'scale',4);
thisR.set('nbounces',3);

%% Find all the materials

results = [];
allMaterials = piMaterialPresets('list');

% Run through them all
fprintf('Testing %d materials.  Requires some time.\n',numel(allMaterials));
for ii = 1:numel(allMaterials)
    try
        % One broken material doesn't cause us to error out
        thisR = piRecipeDefault('scene name','bunny');
        thisR.set('skymap','room.exr');
        thisR.set('asset',bunnyID,'scale',4);
        thisR.set('nbounces',3);
        piMaterialsInsert(thisR,'names',allMaterials{ii});
        thisR.set('asset',bunnyID,'material name',allMaterials{ii});
        piWRS(thisR,'render flag','hdr','show',getpref('ISET3d','show'));
        results = cat(1,results,sprintf("Material: %s Succeeded\n",allMaterials{ii}));
    catch EX
        results = cat(1,results, sprintf("Material: %s FAILED: %s\n",allMaterials{ii},EX.message));
    end
end

%% Print out the results

fprintf('Material test results:\n');
for ii = 1:numel(results)   
    fprintf(results{ii});
end

%% END

