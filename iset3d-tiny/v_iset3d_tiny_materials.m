%% v_iset3d_tiny_materials
% 
% See also
%   v_iset3d_materialsAll (development)
%
% TODO:  
%   We do not have textures or materials in the database.  Should we?

%% 
ieInit
if ~piDockerExists, piDockerConfig; end

fprintf('Testing four materials\n');

%% Red
thisR = piRecipeDefault('scene name','bunny');

thisR.set('skymap','room.exr');
bunnyIDX = piAssetSearch(thisR,'object name','Bunny');
thisR.set('asset',bunnyIDX,'scale',4);
thisR.set('nbounces',3);

piMaterialsInsert(thisR,'names','glossy-red');
thisR.set('asset',bunnyIDX,'material name','glossy-red');
piWRS(thisR);

%% 
piMaterialsInsert(thisR,'names','glossy-black');
thisR.set('asset',bunnyIDX,'material name','glossy-black');
piWRS(thisR);

%% Now a few at at time
thisR = piRecipeDefault('scene name','bunny');

thisR.set('skymap','room.exr');
thisR.set('asset',bunnyIDX,'scale',4);
thisR.set('nbounces',5);

%% Mirror 
piMaterialsInsert(thisR,'names',{'mirror','glass'});
thisR.set('asset',bunnyIDX,'material name','mirror');
piWRS(thisR);

%% Glass
thisR.set('asset',bunnyIDX,'material name','glass');
piWRS(thisR);

%% End
