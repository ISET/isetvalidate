%% v_iset3d_text
% 
% Validation for inserting text into a recipe
% 
% Make the double character instance work

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Original way with textRender

thisR = piRecipeCreate('macbeth checker');
piMaterialsInsert(thisR,'name','wood-light-large-grain');
to = thisR.get('to') - [0.5 0 -0.8];
delta = [0.15 0 0];
str = 'Lorem';
pos = zeros(numel(str),3);
for ii=1:numel(str), pos(ii,:) = to + ii*delta; end

pos(end,:) = pos(end,:) + delta/2;  % Move the 'm' a bit
thisR = textRender(thisR, str,'letterSize',[0.15,0.1,0.15],'letterRotation',[0,15,15],...
    'letterPosition',pos,'letterMaterial','wood-light-large-grain');
thisR.set('skymap','sky-sunlight.exr');
thisR.set('nbounces',4);
piWRS(thisR);

%% This now renders the same way as above

thisR = piRecipeCreate('macbeth checker');
thisR.set('skymap','sky-sunlight.exr');
thisR.set('nbounces',4);

piMaterialsInsert(thisR,'name','wood-light-large-grain');

% str = 'Lorem';
str = 'Lorem';
piTextInsert(thisR,str);
% thisR.show;

% Letter positions as above
to = thisR.get('to') - [0.5 0 -0.8];
delta = [0.15 0 0];
pos = zeros(numel(str),3);
for ii=1:numel(str), pos(ii,:) = to + ii*delta; end
pos(end,:) = pos(end,:) + delta/2;  % Move the 'm' a bit

% Letter sizes as in textRender
characterAssetSize = [.88 .25 1.23];
letterScale = [0.15,0.1,0.15] ./ characterAssetSize;

% Matching the rotate/translate/scale operations with textRender
for ii=1:numel(str)
    idx = piAssetSearch(thisR,'object name',['_',str(ii),'_']);
    thisR.set('asset',idx, 'material name','wood-light-large-grain');

    % This seems to match textRender
    thisR.set('asset',idx, 'rotate', [0,15,15]);
    thisR.set('asset',idx, 'rotate', [-90 00 0]);
    thisR.set('asset',idx, 'translate',pos(ii,:));
    thisR.set('asset',idx, 'scale', letterScale);
end

piWRS(thisR);

%% Deal with instances

% Converting everything into an instance. This alone changes nothing
% in the rendering because the instances are the same as the original.
piObjectInstance(thisR);
thisR.assets = thisR.assets.uniqueNames;

thisR.show('instances');
piWRS(thisR);

%%  Change the position of the uppercase L  

% Maybe this should be thisR.get('asset',idx,'top branch')
thisLetter = piAssetSearch(thisR,'object name','_l_uc');
p2Root = thisR.get('asset',thisLetter,'pathtoroot');
idx = p2Root(end);

% The 'position' seems to mean a translation
piObjectInstanceCreate(thisR, idx, 'position',[-0.1 0 0.0]);
piObjectInstanceCreate(thisR, idx, 'position',[0 0.1 0.0]);
thisR.assets = thisR.assets.uniqueNames;

% We want to implement a return of instances that contain a string in
% their name 
%
%   thisR.get('instances','name',param)
%
id = thisR.get('instances');
for ii=1:numel(id)
    thisR.get('node',id(ii),'name');
    if contains(thisR.get('node',id(ii),'name'),'l_uc')
        fprintf('%s \n',thisR.get('node',id(ii),'name'));
    end
end

piWRS(thisR);

%% END