function varargout = igrd(fn,crop)
%IGRD	Import DEM in .GRD formats (Surfer, ArcInfo / GMT).
%	[X,Y,Z]=IGRD(FILENAME) returns the Digital Elevation Model data
%	defined by X and Y (vectors or matrix) and matrix Z of elevations.
%	FILENAME is a file using one the data grid .GRD formats:
%      - Golden Sofware Surfer (ASCII or binary),
%      - Arc/Info (ASCII),
%      - Generic Mapping Tool (ASCII only).
%
%   IGRD(FILENAME,[X1 X2 Y1 Y2]) will crop the grid using area limits
%   [X1,X2] for X, and [Y1,Y2] for Y.
%
%   G=IGRD(...) returns a structure G with fields:
%      x: X vector
%      y: Y vector
%      z: Z matrix
%
%	NoData values are replaced by NaN.
%
%	Author: François Beauducel, IPG Paris.
%	Created: 1996
%	Updated: 2022-05-23
%
%	References:
%	   Golden Software Surfer, http://www.goldensoftware.com/
%	   GMT (Generic Mapping Tools), http://gmt.soest.hawaii.edu

%	Copyright (c) 1996-2022, François Beauducel, covered by BSD License.
%	All rights reserved.
%
%	Redistribution and use in source and binary forms, with or without
%	modification, are permitted provided that the following conditions are
%	met:
%
%	   * Redistributions of source code must retain the above copyright
%	     notice, this list of conditions and the following disclaimer.
%	   * Redistributions in binary form must reproduce the above copyright
%	     notice, this list of conditions and the following disclaimer in
%	     the documentation and/or other materials provided with the distribution
%
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%	POSSIBILITY OF SUCH DAMAGE.

% lauch Open File dialog box if no file is specified
if nargin < 1
	[f,p] = uigetfile('*.grd','Select the GRD file');
	fn = [p,f];
end

ndv = -99999;                % default NoValue

if ~exist(fn,'file')
	error('File "%s" not found.',fn);
end

fprintf('IGRD: importing "%s"...\n',fn);

fid = fopen(fn, 'r');
line = fgets(fid);             % reads 1st line header

% case of Golden Software/Surfer grid ASCII file
if regexpi(line,'^DSAA')
	sz = fscanf(fid, '%d', [1 2]);
	xm = fscanf(fid, '%f', 2);
	ym = fscanf(fid, '%f', 2);
	zm = fscanf(fid, '%f', 2);
    fprintf('--> found GS/Surfer ascii grid: %dx%d, xlim = [%g %g], ylim = [%g %g], zlim = [%g %g] ...',sz,xm,ym,zm);
	z = fscanf(fid, '%f', sz)';
    fprintf(' done.\n');

% case of Golden Software/Surfer grid BINARY file
elseif regexpi(line,'^DSBB')
	fclose(fid);
	fid = fopen(fn,'rb');
	co = fscanf(fid,'%c',4);
	sz = fread(fid,2,'int16')';
	xm = fread(fid,2,'float64')';
	ym = fread(fid,2,'float64')';
	zm = fread(fid,2,'float64')';
    fprintf('--> found GS/Surfer binary grid: %dx%d, xlim = [%g %g], ylim = [%g %g], zlim = [%g %g] ...',sz,xm,ym,zm);
	z = reshape(fread(fid,'float32'),sz)';
    fprintf(' done.\n');

% case of ESRI/ArcInfo grid ASCII file (added in 2009)
elseif regexpi(line,'^ncols')
	s = textscan(line,'%s');

	% the two formats exist: 'ncols xx' or 'xx ncols'...
	if strcmpi(s{1}(1),'ncols')
		x = 1;
		v = 2;
		cf = '%s%n';
	else
		x = 2;
		v = 1;
		cf = '%n%s';
	end
	sz(1) = str2double(s{1}{v});

	for i = 1:6
		line = fgets(fid);
		s = textscan(line,cf);
		if isscalar(s{v})
			switch lower(s{x}{:})
			case 'nrows'
				sz(2) = s{v};
			case {'xllcenter','xll'}
				xm(1) = s{v};
                dx2 = 0;
			case 'xllcorner'
				xm(1) = s{v};
                dx2 = 1;
			case {'yllcenter','yll'}
				ym(1) = s{v};
                dy2 = 0;
            case 'yllcorner'
				ym(1) = s{v};
                dy2 = 1;
			case 'cellsize'
				csx = s{v};
				csy = s{v};
			case 'dx'
				csx = s{v};
			case 'dy'
				csy = s{v};
			case 'nodata_value'
				ndv = s{v};
				break
			otherwise
				warning('"%s" (=%g) header unknown.\n',s{x}{:},s{v})
			end
		else
			% it happens that files have only 5 lines of header (instead of 6)
			fseek(fid,-length(line),'cof');
		end
	end
	xm(2) = xm(1) + (sz(1)-1)*csx;
	ym(2) = ym(1) + (sz(2)-1)*csy;	% note the reverse order of Y-axis vector
    % applies half cell size if corner origin
    xm = xm + dx2*csx/2;
    ym = ym - dy2*csy/2;
    fprintf('--> found ESRI/ArcInfo ascii grid: %dx%d, xlim = [%g %g], ylim = [%g %g] ...',sz,xm,ym);
	z = flipud(fscanf(fid, '%f', sz)');	% transform needed because Z values are sorted rowwise
    fprintf(' done.\n');

elseif regexpi(line,'^CDF')
	error('"%s" is a binary netCDF grid file. Cannot be read, yet...\nConvert it first using "gmt grd2xyz -Ef" command.',fn)
else
	error('"%s" is not a valid GRD file for this function.',fn)
end

fclose(fid);

x = linspace(xm(1),xm(2),sz(1));
y = linspace(ym(1),ym(2),sz(2))';

% crop
if nargin > 1
	kx = (x >= crop(1) & x <= crop(2));
	ky = (y >= crop(3) & y <= crop(4));
	x = x(kx);
	y = y(ky);
	z = z(ky,kx);
end

% replace NoData values by NaN
z(z == ndv | abs(z) > 1e38) = NaN;

if nargout == 3
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;    
else
    varargout{1} = struct('x',x,'y',y,'z',z);
end
