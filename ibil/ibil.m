function [x,y,z] = ibil(f,crop)
%IBIL read ESRI BIL raster files
%	[X,Y,Z] = IBIL(F) imports files F.bin and F.hdr in coordinates vectors
%	X and Y, and elevation matrix Z.
%
%	[X,Y,Z] = IBIL(F,[XMIN XMAX YMIN YMAX]) crops at X/Y limits.
%
%	DEM = IBIL(...) returns DEM struct:
%	  lat: latitude vector (Y)
%	  lon: longitude vector (X)
%	    z: elevation matrix (in meters)
%
%	F must be a filename without extension, pointing to F.bin and F.hdr
%
%	For example, get ETOPO1 data files at:
%	https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/bedrock/grid_registered/binary/etopo1_bed_g_i2.zip
%
%	Author: F. Beauducel, WEBOBS/IPGP
%	Created: 2013-09-14, Paris, France
%	Updated: 2016-12-22


cropflag = 0;
if nargin > 1 && numel(crop) == 4
	cropflag = 1;
end

fd = [f,'.bin'];
fh = [f,'.hdr'];

%fprintf('WEBOBS{ibil}: importing "%s" file... ',fd);

if ~exist(fd,'file')
	error('Cannot find data file %s',fd)
end
if exist(fh,'file')
	fid = fopen(fh,'rt');
	s = textscan(fid,'%s %s');
	fclose(fid);
else
	error('Cannot find header file %s',fh)
end

for h = 1:length(s{1})
	eval(sprintf('X.%s=''%s'';',s{1}{h},upper(s{2}{h})));
end

ncols = str2double(X.NCOLS);
nrows = str2double(X.NROWS);
xll = str2double(X.XLLCENTER);
yll = str2double(X.YLLCENTER);
cellsize = str2double(X.CELLSIZE);

switch(X.BYTEORDER)
	case 'LSBFIRST'
		byteorder = 'l';
	otherwise
		byteorder = 'b';
end

switch(X.NUMBERTYPE)
	case '2_BYTE_INTEGER'
		ntype = 'int16';
		stype = 2;
	case '4_BYTE_FLOAT'
		ntype = 'single';
		stype = 4;
	otherwise
		ntype = 'int16';
		stype = 2;
end

% this method works but resulting cellsize not exactly constant !
%x = linspace(xll,xll + cellsize*(ncols-1),ncols);
%y = linspace(yll,yll + cellsize*(nrows-1),nrows);
% thus prefered the following:
x = xll + (0:cellsize:(ncols-1)*cellsize);
y = yll + (0:cellsize:(nrows-1)*cellsize);
dx = 0;
nrowsread = nrows;

fid = fopen(fd,'rb',byteorder);

if cropflag
	%crop(3) = max(crop(3),min(y));
	%crop(4) = min(crop(4),max(y));
	kx = find(x >= min(crop(1:2)) & x <= max(crop(1:2)));
	if isempty(kx)
		dx = -360;
		kx = find((x+dx) >= min(crop(1:2)) & (x+dx) <= max(crop(1:2)));
	end
	ky = find(y >= min(crop(3:4)) & y <= max(crop(3:4)));
	fseek(fid,(nrows - ky(end))*ncols*stype,'bof');
	nrowsread = length(ky);
end

z = fread(fid,[ncols,nrowsread],ntype);
fclose(fid);

if cropflag
	x = x(kx)+dx;
	y = y(ky);
	z = z(kx,:);
end
z = flipud(z');

if nargout < 3
	x = struct('lon',x,'lat',y,'z',z);
end

%fprintf('done.\n');

