# mapping-lib
Various mapping functions mostly written in Matlab/Octave (but Python equivalent will come): DEM manipulation, SRTM automatic download, topographic maps, coordinates convert and paths, ...

## Topographic grids
- ### [READHGT](readhgt)
  Download/read NASA SRTM worldwide topographic data files (.HGT).

- ### [DEM](dem)
  Shaded relief image plot for digital elevation models.

- ### [WHEREAMI](https://github.com/beaudu/whereami)
  Automatic geolocation map (other repository).

- ### [IBIL](ibil)
  Import ESRI BIL raster binary files.

- ### [IGRD and EGRD](grd)
  Import and export ESRI/Arcinfo and GS/Surfer ASCII or binary GRD DEM files.

- ### [NANINTERP2](https://github.com/beaudu/naninterp2)
  2-D optimized linear interpolation to fill gaps in a grid (other repository).

## Coordinates and paths
- ### [LL2UTM and UTM2LL](latlonutm)
  Latitude/longitude to and from UTM coordinates precise and vectorized conversion.

- ### [GREATCIRCLE and LOXODROME](greatcircle)
  Shortest and rhumb line path, distance and bearing.

- ### [RADIOCOVER](radiocover)
  Radio link coverage map.

## Graphics
- ### [COMPROSE](comprose)
  Compass rose plot.

- ### [ARROWS](arrows)
  Generalized 2-D arrows plot.

- ### [POLARMAP](polarmap)
  Polarized color map.


## Author
**François Beauducel**, [IPGP](www.ipgp.fr), [beaudu](https://github.com/beaudu), beauducel@ipgp.fr

## Documentation
All functions contain in-line help for syntax and examples.
