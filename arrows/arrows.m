function varargout=arrows(x,y,l,az,varargin)
%ARROWS  Generalized 2-D arrows plot
%	ARROWS(X,Y,L,AZ) or ARROWS(X,Y,L,AZ,'Polar') draws an arrow on the
%	current axis at position X,Y with length L and azimuth AZ (in degrees,
%	clockwise from positive Y-axis direction).
%
%	ARROWS(X,Y,U,V,'Cartesian') uses arrows cartesian components U,V
%	instead of length/azimuth. This is an equivalent of QUIVER(X,Y,U,V,0).
%
%	ARROWS(X,Y,R,AZ,'Loop') draws a clockwise loop arrow of radius R and 
%	offset azimuth angle AZ (in degrees). Use negative value of R for a
%	counter clockwise loop.
%
%	X and Y can be scalars or matrix. In the last case, ARROWS will draw as
%	many arrows as elements of X and Y. Any or both pairs of parameters 
%	L/AZ, U/V or R/AZ can be scalars or matrix of the same size as X and Y.
%
%	ARROWS(...,SHAPE) uses relative ratios SHAPE = [HEADW,HEADL,HEADI,LINEW]
%	to adjust head width HEADW, head length HEADL, head inside length HEADI,
%	and segment line width LINEW for an arrow length of 1 or 2*PI for the
%	'Loop' type. Default is SHAPE = [0.2,0.2,0.15,0.05].
%
%	ARROWS(...,'Ref',R) defines a reference length R for which SHAPE
%	parameters applies. Any other lengths will keep the arrow's header size
%	and line width as for the reference.
%
%	ARROWS(...,'param1',value1,'param2',value2,...) specifies any
%	additionnal properties of the Patch using standard parameter/value
%	pairs, like 'FaceColor','EdgeColor','LineWidth', ...
%
%	H=ARROWS(...) returns graphic's handle of patches.
%
%	Examples:
%
%	  arrows(0,0,1,45,'FaceColor','none','LineWidth',3)
%
%	  arrows(1,0,1,0,[.2,.4,.2,.02])
%
%	  [xx,yy] = meshgrid(1:10);
%	  arrows(xx,yy,rand(size(xx)),360*rand(size(xx)))
%
%
%	Notes:
%
%	- Arrow shape supposes an equal aspect ratio (axis equal).
%	- To define an arrow without segment line, set HEADI = 1, LINEW = 0,
%	  and adjust other shape parameters, e.g., a triangle is defined by
%	  SHAPE = [0.5,1,1,0], while a "wind arrow" is [1,1.5,1,0].
%	- To make arrows in 3-D, use the powerful Matlab's function ROTATE.
%
%       See also PATCH, QUIVER.
%
%	Author: François Beauducel <beauducel@ipgp.fr>
%	Created: 1995-02-03
%	Updated: 2020-06-11

%	Copyright (c) 2020, François Beauducel, covered by BSD License.
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

if nargin < 4
	error('Not enough input arguments.')
end

if ~isnumeric(x) || ~isnumeric(y) || ~isnumeric(l) || ~isnumeric(az)
	error('X, Y, L/AZ, U/V or R/AZ must be numeric.')
end

n = max([numel(x) numel(y) numel(l) numel(az)]);	% max size of arguments

% default arrow shape
shape = [.2 .2 .15 .05];

% checks the arrow type
types = {'polar','cartesian','loop'};

type = 'polar'; % default arrow type
for i = 1:length(types)
	k = strcmpi(varargin,types{i});
	if any(k)
		type = types{i};
		varargin(k) = [];
	end
end

% reference length option
k = find(strcmpi(varargin,'ref'));
if ~isempty(k) && nargin>4+k
	refl = varargin{k+1};
	varargin(k+[0,1]) = [];
else
	refl = 0;
end

if ~isempty(varargin) && isnumeric(varargin{1})
	shape = varargin{1}(:)';
	if numel(shape) ~= 4
		error('SHAPE argument must be a 4-scalar vector.')
	end

	% this adjusts head drawing for HEADI = 0 and LINEW > 0
	shape(3) = max(shape(3),shape(4)*shape(2)/shape(1));
	varargin = varargin(2:end);
end

mline = 2;

switch type
	case 'loop'
		mline = 50; % additionnal line points for loop arrow
		az = az*pi/180;
		shape(2:3) = shape(2:3)/(2*pi);
	case 'cartesian'
		% converts U,V to AZ,L
		[az,l] = cart2pol(l,az);
		az = pi/2 - az;
	otherwise
		az = az*pi/180;
end

% total number of arrow points (see fx vector below)
m = 4 + 2*mline;

% needs to duplicate non-scalar arguments
x = repval(x,m);
y = repval(y,m);
l = repval(l,m);
az = repval(az,m);

if refl
	s = refl*(1./abs(l(1,:))')*shape;
	s(isinf(s)) = 0;	% because 0-length arrows produced Inf shape elements...
else
	s = repmat(shape,[n,1]);
end

v0 = zeros(n,1);
v1 = ones(n,1);
vl = linspace(0,1,mline);

% unit length arrow patch
fx = [s(:,4)*[.5 -.5*ones(1,mline)] s(:,1)*[-.5 0 .5] s(:,4)*.5*ones(1,mline)]';
fy = [v0 (1 - s(:,3))*vl (1 - s(:,2)) v1 (1 - s(:,2)) (1 - s(:,3))*fliplr(vl)]';

switch type
	case 'loop'
		th = pi/2 - fy*7*pi/4 - az; % arrow length converted to 7/8 angle loop 
		px = l.*(cos(th) + fx.*cos(th));
		py = l.*(sin(th) + fx.*sin(th));
	otherwise
		px = l.*(-fx.*cos(az) + fy.*sin(az));
		py = l.*(fx.*sin(az) + fy.*cos(az));
end

% the beauty of this script: a single patch command to draw all the arrows !
h = patch(px + x,py + y,'k',varargin{:});

	
if nargout > 0
	varargout{1} = h;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = repval(x,n)

if numel(x) > 1
	x = repmat(x(:)',[n,1]);
end
