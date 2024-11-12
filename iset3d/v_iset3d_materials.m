%% v_iset3d_materials
% 
% See also
%   v_iset3d_materialsAll (development)
%
% TODO:  
%   We do not have textures or materials in the database.  Should we?

%% 
ieInit
if ~piDockerExists, piDockerConfig; end
showFlag = false;
speedFlag = 4;

%% Red
thisR = piRecipeDefault('scene name','bunny');

thisR.set('skymap','room.exr');
bunnyIDX = piAssetSearch(thisR,'object name','Bunny');
thisR.set('asset',bunnyIDX,'scale',4);
thisR.set('nbounces',3);

piMaterialsInsert(thisR,'names','glossy-red');
thisR.set('asset',bunnyIDX,'material name','glossy-red');
scene = piWRS(thisR,'speed',speedFlag);

% Check the total number of photons is close in this first scene
p = sceneGet(scene,'photons');
assert(abs(sum(p(:))/7.0357e+20 - 1) < 0.05);

%% 
piMaterialsInsert(thisR,'names','glossy-black');
thisR.set('asset',bunnyIDX,'material name','glossy-black');
piWRS(thisR,'show',showFlag,'speed',speedFlag);

%% Now a few at at time
thisR = piRecipeDefault('scene name','bunny');

thisR.set('skymap','room.exr');
thisR.set('asset',bunnyIDX,'scale',4);
thisR.set('nbounces',5);

%% Mirror 
piMaterialsInsert(thisR,'names',{'mirror','glass'});
thisR.set('asset',bunnyIDX,'material name','mirror');
piWRS(thisR,'show',showFlag,'speed',speedFlag);

%% Glass
thisR.set('asset',bunnyIDX,'material name','glass');
piWRS(thisR,'show',showFlag,'speed',speedFlag);

fprintf('Tested four materials.\n');
%% End
