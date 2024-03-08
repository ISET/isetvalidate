%% v_iset3d_recipeValidation
%
% Validating the piRecipeCreate reads all the recipes in data/scenes.
% Some need a little help to render. Say a skymap or some materials.
%
% This can take a while.
%
% See also
%

%%
ieInit;
if ~piDockerExists, piDockerConfig; end
validNames = piRecipeCreate('list');

%% This loop should work.

status = zeros(1,numel(validNames));

fprintf('Testing %d different scenes\n',numel(validNames));
for ii=1:numel(validNames)
    fprintf('\n-----------\n');
    fprintf('Scene:  %s\n',validNames{ii})
    try
        thisR = piRecipeCreate(validNames{ii});
        piWRS(thisR,'show',getpref('ISET3d','show'));
        status(ii) = 1;
    catch
        status(ii) = 0;
    end
end

%% List the summary

status = logical(status);

cprintf([0.2 0.6 0.2],'\nSucceeded:\n')
tmp = validNames(status);
for ii=1:numel(tmp)
    fprintf('%s\n',tmp{ii});
end

cprintf([0.7 0.2 0.2],'\n\nFailed:\n')
tmp = validNames(~status);
for ii=1:numel(tmp)
    fprintf('%s\n',tmp{ii});
end

%% END

