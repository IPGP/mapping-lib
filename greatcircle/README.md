# Shortest and rhumb line path, distance and bearing

## greatcircle.m
The function GREATCIRCLE computes the shortest path along the great circle ("as the crow flies") between two points defined by their geographic coordinates (latitude and longitude). With one output argument it returns distance or vector of distances, with two or more output arguments it returns path coordinates and optional vector of distances and bearing angles along the path.

Example:
```matlab
load topo
contour(0:359,-89:90,topo,[0,0],'k')
[lat,lon,dis] = greatcircle(48.8,2.3,35.7,139.7);
hold on, plot(lon,lat,'r','linewidth',2), hold off
title(sprintf('Paris to Tokyo = %g km',dis(end)))
```

## loxodrome.m
The function LOXODROME computes the path with a constant bearing, crossing all meridians of longitude at the same angle. It returns also a vector of distances and the bearing angle.

Example:
```matlab
load topo
contour(0:359,-89:90,topo,[0,0],'k')
[lat,lon,dis,bear] = loxodrome(48.8,2.3,35.7,139.7);
hold on, plot(lon,lat,'r','linewidth',2), hold off
title(sprintf('Paris to Tokyo = %g km - bear = %g N',dis(end),bear))
```

Loxodrome path (also known as "rhumb line") is longer than great circle one, but still used in navigation as it is easier to follow with a compass.

![greatcircle example](greatcircle_example.png)

Type 'doc greatcircle' or 'doc loxodrome' for syntax, help and examples.
