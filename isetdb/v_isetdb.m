% v_isetdb
%
% Validation tests for the isetdb connection
%

thisDB = isetdb;

%% Find all the available collections

thisDB.collectionList;


%% Find available categories

% TODO

%% For this collection (PBRTResources) find buses and cars

collectionName = 'PBRTResources';

assets = thisDB.contentFind(collectionName, 'category','bus','type','asset', 'show',true);
fprintf('Found %d bus assets.\n',numel(assets));

assets = thisDB.contentFind(collectionName, 'category','car','type','asset');
fprintf('Found %d car assets.\n',numel(assets));

assets = thisDB.contentFind(collectionName, 'category','car','type','scene', 'show',true);
fprintf('Found %d car scenes.\n',numel(assets));

assets = thisDB.contentFind(collectionName, 'category','car','type','asset');
fprintf('Found %d cars\n',numel(assets));

%%
