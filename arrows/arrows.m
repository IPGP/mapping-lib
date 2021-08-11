function varargout=arrows(x,y,l,az,varargin)
%ARROWS  Generalized 2-D arrows plot
%	ARROWS(X,Y,L,AZ) or ARROWS(X,Y,L,AZ,'Polar') draws an arrow on the
%	current axis at position X,Y with length L and azimuth AZ (in degrees,
%	clockwise from positive Y-axis direction).
%
%	ARROWS(X,Y,U,V,'Cartesian') uses arrows cartesian components U,V
%	instead of length/azimuth. This is an equivalent of QUIVER(X,Y,U,V,0).
%
%	ARROWS(X,Y,R,AZ,'Loop') draws a clockwise 3/4 loop arrow of radius R 
%	and offset azimuth angle AZ (in degrees). Use negative value of R for a
%	counter clockwise loop.
%
%	X and Y can be scalars or matrix. In the last case, ARROWS will draw as
%	many arrows as elements of X and Y. Any or both pairs of parameters 
%	L/AZ, U/V or R/AZ can be scalars or matrix of the same size as X and Y.
%
%	ARROWS(...,SHAPE) uses relative ratios SHAPE = [HEADW,HEADL,HEADI,LINEW]
%	to adjust head width HEADW, head length HEADL, head inside length HEADI,
%	and segment line width LINEW for an arrow length of 1. Default is 
%	SHAPE = [0.2,0.2,0.15,0.05].
%	For the 'Loop' arrow type, the reference length for SHAPE parameters is
%	not 1 but 2*PI. An additional parameter can be specified as the total 
%	angle of rotation (in degree, default is 315°): SHAPE = [...,AROT].
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
%	  arrows(0,0,-1,45,'Loop')
%
%	  [xx,yy] = meshgrid(1:10);
%	  arrows(xx,yy,rand(size(xx)),360*rand(size(xx)))
%
%
%	Notes:
%	- Arrow shape supposes an equal aspect ratio (axis equal).
%	- To define an arrow without segment line, set HEADI = 1, LINEW = 0,
%	  and adjust other shape parameters, e.g., a triangle is defined by
%	  SHAPE = [0.5,1,1,0], while a "wind arrow" is [1,1.5,1,0].
%	- To make a two-ends arrow, use AZ=[0,180] in the 'Polar' default mode.
%	- To make arrows oriented in 3-D, use the powerful Matlab's function
%	  ROTATE.
%
%       See also PATCH, QUIVER.
%
%	Author: François Beauducel <beauducel@ipgp.fr>
%	Created: 1995-02-03
%	Updated: 2020-06-23

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

% default arrow shape: HeadWidth, HeadLength, HeadInsideLength, LineWidth, LoopAngle
shape = [.2 .2 .15 .05 315];

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
	if all(numel(varargin{1}) ~= [4,5])
		error('SHAPE argument must be a 4 or 5-scalar vector.')
	end
	shape(1:length(varargin{1})) = varargin{1}(:)';

	% this adjusts head drawing for HEADI = 0 and LINEW > 0
	shape(3) = max(shape(3),shape(4)*shape(2)/shape(1));
	varargin = varargin(2:end);
end

mline = 2;
loopl = shape(5)*pi/180;

switch type
	case 'loop'
		mline = 50; % additionnal line points for loop arrow
		az = az*pi/180;
		shape(2:3) = shape(2:3)/loopl;
	case 'cartesian'
		% converts U,V to AZ,L
		[az,l] = cart2pol(l,az);
		az = pi/2 - az;
	otherwise
		az = az*pi/180;
end

% total number of arrow points (see fx vector below)
m = 4 + 2*mline;

% needs to duplicate arguments
x = repmat(x(:)',[m,1]);
y = repmat(y(:)',[m,1]);
l = repmat(l(:)',[m,1]);
az = repmat(az(:)',[m,1]);

% s is a matrix of shape vectors
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
fx = [s(:,1)*[-.5  0  .5]          s(:,4)*.5*[ones(1,mline) 1 -ones(1,mline)]]';
fy = [(1 - s(:,2)) v1 (1 - s(:,2)) (1 - s(:,3))*fliplr(vl) v0 (1 - s(:,3))*vl]';

switch type
	case 'loop'
		th = pi/2 - fy*loopl - az; % arrow length converted to angle loop 
		px = l.*cos(th).*(1 + fx);
		py = l.*sin(th).*(1 + fx);
		% head must be redrawn to avoid distortion...
		kh = 1:3; % indexes of the head's 3-points to be moved
		xh = -l(kh,:).*flipud(fx(kh,:));
		yh = -l(kh,:).*((s(:,3) - [s(:,2) v0 s(:,2)])')*loopl;
		a0 = repmat(th(4,:),3,1); % head rotation angle
		% rotates and tranlates the head at the right position
		px(kh,:) = cos(a0).*xh - sin(a0).*yh + repmat(mean(px([4,end],:)),3,1);
		py(kh,:) = sin(a0).*xh + cos(a0).*yh + repmat(mean(py([4,end],:)),3,1);
		
	otherwise
		px = l.*(-fx.*cos(az) + fy.*sin(az));
		py = l.*(fx.*sin(az) + fy.*cos(az));
end

% the beauty of this script: a single patch command to draw all the arrows !
h = patch(px + x,sign(l).*py + y,'k',varargin{:});
	
if nargout > 0
	varargout{1} = h;
end
