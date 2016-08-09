# Latitude/longitude to and from UTM coordinates precise and vectorized conversion

## ll2utm.m
LL2UTM converts latitude/longitude coordinates to UTM.

## utm2ll.m
UTM2LL converts Universal Transverse Mercator (UTM) East/North coordinates to latitude/longitude.


Both functions are using precise formula (millimeter precision), possible user-defined datum (WGS84 is the default), and are all vectorized (no loop in the code). It means that huge matrix of points, like an entire DEM grid, can be converted very fast.

Example (needs readhgt.m author's function):

```matlab
X = readhgt(36:38,12:15,'merge','crop',[36.5,38.5,12.2,16],'plot');
[lon,lat] = meshgrid(X.lon,X.lat);
[x,y,zone] = ll2utm(lat,lon);
z = double(X.z);
z(z==-32768 | z<0) = NaN;
figure
pcolor(x,y,z); shading flat; hold on
contour(x,y,z,[0,0],'w')
hold off; axis equal; axis tight
xlabel('East (m)'); ylabel('North (m)')
title(sprintf('Sicily - UTM zone %d WGS84',zone))
```

loads SRTM full resolution DEM of Sicily in lat/lon (a 2400x4500 grid), converts it to UTM and plots the result. To make a regular UTM grid, you may interpolate x and y with griddata function.

See "doc ll2utm" and "doc utm2ll" for syntax and help.

