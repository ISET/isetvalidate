%% Chart validation
%
%  v_chart
%
%

%%
ieInit

%%
scene = sceneCreate('macbeth d65');
% sceneWindow(scene);
%  cornerPoints = chartCornerpoints(scene,true);
cornerPoints = [1    65
    96    64
    96     1
    1     1];
scene = sceneSet(scene,'corner points',cornerPoints);
cPoints = sceneGet(scene,'corner points');
assert(isequal(cPoints,cornerPoints));

% The MCC is 4 x 5
rects = chartRectangles(cornerPoints,4,6,0.5);
scene = sceneSet(scene,'chart rectangles',rects);
newRects = sceneGet(scene,'chart rects');
assert(isequal(rects,newRects));

sceneWindow(scene); chartRectsDraw(scene,rects);

%% Now the oi
oi = oiCreate;
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');

cornerPoints = chartCornerpoints(oi,true);
rects = chartRectangles(cornerPoints,4,6,0.5);
oi = oiSet(oi,'chart rectangles',rects);
newRects = oiGet(oi,'chart rects');
assert(isequal(rects,newRects));
oiWindow(oi); chartRectsDraw(oi,rects);


%% Now the sensor

sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',1.3*sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);

% cornerPoints = chartCornerpoints(sensor);
cornerPoints = ...
    [38   208
    276   210
    276    50
    39    48];
rects = chartRectangles(cornerPoints,4,6,0.5);
sensor = sensorSet(sensor,'chart rectangles',rects);
newRects = sensorGet(sensor,'chart rects');
assert(isequal(rects,newRects));

sensorWindow(sensor); chartRectsDraw(sensor,rects);

%% IP

ip = ipCreate;
ip = ipCompute(ip,sensor);

% ipWindow; cornerPoints = chartCornerpoints(ip);
cornerPoints = ...
    [39   207
   278   209
   278    50
    39    50];
rects = chartRectangles(cornerPoints,4,6,0.5);
ip = ipSet(ip,'chart rectangles',rects);
newRects = ipGet(ip,'chart rects');
assert(isequal(rects,newRects));

ipWindow(ip); chartRectsDraw(ip,rects);

%% END





