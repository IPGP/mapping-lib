function m = radiocover(x,y,z,x0,y0,h0,ha,method)
%RADIOCOVER Radio link coverage map on topography.
%	RADIOCOVER(X,Y,Z,X0,Y0,H0,Ha) computes the coverage map of possible 
%	direct linear radio link from the point (X0,Y0) with antenna height H0,  
%	using digital terrain model defined by coordinate vectors X and Y, and 
%	elevation matrix Z, and hypothetic antenna height Ha, then plots a 
%	color map of the relative elevation mask angle (in degrees) with blank
%	areas where there is no mask (visible), together with a contour map
%	of the topography.
%
%	X and Y can be vectors with length(X) = n and length(Y) = m where
%	[m,n] = size(Z), or matrices of the same size as Z (as from MESHGRID).
%
%	RADIOCOVER(...,METHOD) specifies alternate methods. The default is
%	nearest neighbor interpolation. Available methods are:
%		'nearest' - nearest neighbor interpolation (default)
%		'linear'  - linear interpolation (smoother result)
%		'fast'    - approximate algorithm (about 2 times faster)
%
%	M = RADIOCOVER(...); returns a matrix of relative elevation mask angle
%	(in degrees, same size as Z), without producing graphic. Visible points 
%	have null or negative values.
%
%	The model assumes linear propagation of radio waves (direct line of 
%	sight between the two antennas), and neglects curvature of the Earth, 
%	Fresnel zone, and atmospheric refraction.
%
%	Example:
%		[x,y,z]=peaks(100);
%		[fx,fy]=gradient(z);
%		z=sqrt(fx.^2+fy.^2);
%		surf(x,y,z), shading flat, light, view(-24,74)
%		radiocover(x,y,z,-0.84,-0.27,.05,.05)
%
%	Author: François Beauducel <beauducel@ipgp.fr>
%	  Institut de Physique du Globe de Paris
%	Created: 2003-01-10
%	Updated: 2013-01-17

%	Copyright (c) 2003-2013, François Beauducel, covered by BSD License.
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

if nargin < 7 | nargin > 8
	error('Number of input arguments not correct.')
end

if ~isnumeric(x0) | ~isnumeric(y0) | ~isnumeric(h0) | ~isnumeric(ha)
	error('X0, Y0, H0 and Ha must be all numeric.')
end

opt = {'nearest','linear','fast'};

if nargin < 8
	method = opt{1};
else
	if ~ischar(method)
		error('METHOD must be a string.')
	end
end

if ~ismember(method,opt)
	error('%s is an invalid method.',method)
end

% needs x and y in meshgrid form
if any(size(x) ~= size(z)) | any(size(y) ~= size(z))
	if length(x(:)) ~= size(z,2) | length(y(:)) ~= size(z,1)
		error('X and Y must be vectors or matrices of compatible size with Z.')
	end
	[x,y] = meshgrid(x,y);
end

% initiates the result matrix
mh = zeros(size(z));

% polar angle and distance from (x0,y0) 
[t,r] = cart2pol(x-x0,y-y0);

% interpolates topography for elevation at (x0,y0)
z0 = interp2(x,y,z,x0,y0,'*nearest') + h0;

% matrix of elevation angles for topography from (x0,y0,z0)
e_top = atan2(z - z0,r);

% matrix of elevation angles for topography+antenna from (x0,y0,z0)
e_ant = atan2(z - z0 + ha,r);

% horizontal pixel size
dy = abs(diff(y(1:2)));

% difficult to vectorize (!) so a horrible global loop seems necessary...
h = waitbar(0,'Processing radiocover...');
for i = 1:numel(z)
	switch method
		case 'fast'
			% selects a line of pixels in the azimuth profile (much faster than interpolation)
			k = find(r <= r(i) & abs(t - t(i)) < dy/r(i));
			if ~isempty(k)
				mh(i) = max(e_top(k) - e_ant(i));
			end
		otherwise
			dr = linspace(0,r(i),round(r(i)/dy));
			dt = t(i)*ones(size(dr));
			[px,py] = pol2cart(dt,dr);
			mh(i) = max(interp2(x-x0,y-y0,e_top,px,py,['*',method]) - e_ant(i));
	end
	if mod(i,size(z,1)*10) == 0
		fprintf('%3.0f%% (%d elements) done.\n',100*i/numel(z),i)
	end
	waitbar(i/numel(z),h);
end

% converts into degrees
mh = mh*180/pi;

if nargout > 0
	m = mh;
else
	figure
	mh(mh<=0) = NaN;
	pcolor(x,y,mh), shading flat
	hold on
	contour(x,y,z,'Color',.9*[1,1,1])
	plot(x0,y0,'pk','MarkerSize',20)
	hold off
	colorbar
	caxis([0,15])
	title('Mask relative elevation angle coverage map')
end
