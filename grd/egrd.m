function egrd(x,y,z,fichier,fmt,ndv)
%EGRD	Export DEM in Surfer or ArcInfo ASCII ".GRD" format.
%	EGRD(X,Y,Z,FILENAME,FORMAT) creates a file FILENAME in ASCII grid 
%	format from a Digital Elevation Model data defined by X and Y (vectors 
%	or matrix from MESHGRID) and matrix Z of elevations.
%
%	Available values for FORMAT are:
%		'surfer'  - Golden Software Surfer format (default)
%		'arcinfo' - ESRI ArcInfo interchange format
%
%	EGRD(...,NODATA) uses NODATA scalar value for NaN Z-points.
%
%	Note: ArcInfo format can be converted into GMT-binary GRD file by
%	using the command "xyz2grd -E". See Generic Mapping Tools packages at
%	http://gmt.soest.hawaii.edu/
%
%	Author: François Beauducel, Institut de Physique du Globe de Paris
%	Created: 1996
%	Updated: 2020-04-26

if nargin < 4 || nargin > 6
	error('Not enough or to much input argument.')
end

opt = {'surfer','arcinfo','gmt'};

if nargin < 5
	fmt = opt{1};
end

if nargin < 6
	ndv = -99999;		% NoDataValue
end

if ~isnumeric(x) || ~isnumeric(y) || ~isnumeric(z)
	error('X, Y, and Z must be all numeric.')
end

if ~ischar(fichier) || ~ischar(fmt)
	error('FILENAME and FORMAT must be strings.')
end

fmt = lower(fmt);

if ~ismember(fmt,opt)
	error('%s is an invalid format.',fmt)
end

if ~isnumeric(ndv) || numel(ndv) > 1
	error('NODATA must be scalar.')
end

if isvector(x)
	xinc = median(diff(x));
else
	xinc = median(diff(x(1,:)));
end
if isvector(y)
	yinc = median(diff(y));
else
	yinc = median(diff(y(:,1)));
end

if yinc < 0
	z = flipud(z);
end

% replaces NaN by NoDataValue
z(isnan(z)) = ndv;

xlim = minmax(x);
ylim = minmax(y);
zlim = minmax(z);

switch fmt
	case opt{1}
		fid = fopen(fichier, 'wt');
		fprintf(fid, 'DSAA\n');
		fprintf(fid, '%d %d\n', fliplr(size(z)));
		fprintf(fid, '%f %f\n', xlim);
		fprintf(fid, '%f %f\n', ylim);
		fprintf(fid, '%f %f\n', zlim);
		for i = 1:size(z,1)
			fprintf(fid, '%g ', z(i,:));
			fprintf(fid, '\n');
		end
		fclose(fid);
	case opt{2}
		fid = fopen(fichier, 'wt');
		fprintf(fid,'ncols %d\n',size(z,2));
		fprintf(fid,'nrows %d\n',size(z,1));
		fprintf(fid,'xllcenter %f\n',xlim(1));
		fprintf(fid,'yllcenter %f\n',ylim(1));
		if abs(yinc) ~= abs(xinc)
    		fprintf(fid,'dx %g\n',abs(xinc));
    		fprintf(fid,'dy %g\n',abs(yinc));
        else
            fprintf(fid,'cellsize %g\n',abs(yinc));
		end
		fprintf(fid,'nodata_value %g\n',ndv);
		for i = size(z,1):-1:1
			fprintf(fid, '%g ', z(i,:));
			fprintf(fid, '\n');
		end
		fclose(fid);
	case opt{3}
		fid = fopen(fichier,'wb');
		fwrite(fid,size(z,2),'int16');			% nx
		fwrite(fid,size(z,1),'int16');			% ny
		fwrite(fid,0,'int16');					% node_offset
		fwrite(fid,xlim,'double');				% x_min,x_max
		fwrite(fid,ylim,'double');				% y_min,y_max
		fwrite(fid,zlim,'double');				% z_min,z_max
		fwrite(fid,abs(xinc),'double');			% x_inc
		fwrite(fid,abs(yinc),'double');			% y_inc
		fwrite(fid,1,'double');					% z_scale_factor
		fwrite(fid,0,'double');					% z_add_offset
		fwrite(fid,repmat(' ',1,4*80),'uchar');	% x,y,z_units & title
		fwrite(fid,repmat(' ',1,380),'uchar');	% command_line
		fwrite(fid,repmat(' ',1,160),'uchar');	% remark
		fwrite(fid,z,'double');
		fclose(fid);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mm = minmax(x)
mm = [min(x(:)),max(x(:))];

