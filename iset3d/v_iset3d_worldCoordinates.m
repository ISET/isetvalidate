% Build this up to test translations and rotations.
%% Initialization
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'simple scene');

% 
thisR.set('film resolution',[200 150]);
thisR.set('rays per pixel',32);
thisR.set('fov',45);
thisR.set('nbounces',5); 

thisR.set('lights','all','delete');
thisR.set('skymap','room.exr');
%%
thisR.assets.print
names = thisR.assets.names;
pos = thisR.get('asset', names{10}, 'world position');
pos = thisR.get('asset', names{26}, 'world position');
pos = thisR.get('asset', names{8}, 'world position');
pos = thisR.get('asset', names{15}, 'world position');
pos = thisR.get('asset', names{17}, 'world position');

rot = thisR.get('asset', names{15}, 'world rotation');
thisR.set('asset', names{15}, 'translation', [1 0 0]);
thisR.set('asset', names{15}, 'rotation', [0 0 45]);
rot = thisR.get('asset', names{15}, 'world rotation');

rot = thisR.get('asset', names{17}, 'world rotation');

%%
piWRS(thisR,'show',getpref('ISET3d','show'));

%%
thisR.set('asset', names{15}, 'translation', [-1 0 0]);

%%
piWRS(thisR,'show',getpref('ISET3d','show'));
