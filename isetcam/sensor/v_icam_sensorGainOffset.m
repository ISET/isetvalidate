% In progress
%
% Not ready.

scene = sceneCreate('uniform');
oi = oiCreate;
oi = oiCompute(oi,scene);
oi = oiCrop(oi,'border');

sensor = sensorCreate;
sensor = sensorSet(sensor,'fov',oiGet(oi,'fov')/2,oi);

sensor = sensorSet(sensor,'exp time',0.05);
sensor = sensorSet(sensor,'analog gain',1);
sensor = sensorCompute(sensor,oi);
v = sensorGet(sensor,'volts');
v1 = mean(v(:))

sensor = sensorSet(sensor,'analog gain',0.25);
sensor = sensorSet(sensor,'exp time',0.05);
sensor = sensorCompute(sensor,oi);
v = sensorGet(sensor,'volts');
v2 = mean(v(:))

v2/v1

