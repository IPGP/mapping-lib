function h=arrows(x,y,l,az,varargin)
%ARROWS  Generalised 2-D arrows plot
%
%	ARROWS(X,Y,L,AZ) draws an arrow on current axis from position X,Y with 
%	length L, oriented with azimuth AZ (in degree, AZ = 0 means an arrow 
%	pointing to positive Y-axis direction, rotating clockwise).
%       
%	X and Y can be scalars or matrix. In the last case, any or both L and
%	AZ can be scalars or matrix of the same size as X and Y.
%
%	ARROWS(...,SHAPE) uses relative ratios SHAPE = [HEADW,HEADL,HEADI,LINEW]
%	to adjust head width HEADW, head length HEADL, head inside length HEADI,
%	and segment line width LINEW for an arrow length of 1 (default is 
%	SHAPE = [0.2,0.2,0.15,0.05]).
%
%	ARROWS(X,Y,U,V,...,'Cartesian') uses arrows cartesian components U,V
%	instead of length/azimuth. This is an equivalent of QUIVER(X,Y,U,V,0).
%
%	ARROWS(...,'Ref',R) defines the length R for which SHAPE reference
%	parameters applies. Other lengths will be adjusted keeping the arrow's
%	header size and line width the same.
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
%	  SHAPE = [0.5,1,1,0], while a "wind arrow" is [1,1.5,1,0]
%
%       See also PATCH, QUIVER.
%
%	Author: Francois Beauducel <beauducel@ipgp.fr>
%	Created: 1995-02-03
%	Updated: 2013-03-16

%	Copyright (c) 2013, François Beauducel, covered by BSD License.
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

if ~isnumeric(x) | ~isnumeric(y) | ~isnumeric(l) | ~isnumeric(az)
	error('X,Y,L and AZ must be numeric.')
end

if nargin > 4 & isnumeric(varargin{1})
	shape = varargin{1}(:)';
	if numel(shape) ~= 4
		error('SHAPE argument must be a 4-scalar vector.')
	end

	% this adjusts head drawing for HEADI = 0 and LINEW > 0
	shape(3) = max(shape(3),shape(4)*shape(2)/shape(1));

	varargin = varargin(2:end);
else
	shape = [.2 .2 .15 .05];
end

[s,cart,varargin] = checkparam(varargin,'cartesian','option');
if ~s
	cart = 0;
end
[s,refl,varargin] = checkparam(varargin,'ref','isscalar');
if ~s
	refl = 0;
end

if cart
	% cartesian components: converts to AZ,L
	[az,l] = cart2pol(l,az);
	az = pi/2 - az;
else
	% converts AZ in degrees to radians
	az = az*pi/180;
end


m = 8; % length of arrow points (see fx vector below)

% needs to duplicate non-scalar arguments
x = repval(x,m);
y = repval(y,m);
l = repval(l,m);
az = repval(az,m);

n = max([size(x,2) size(y,2) size(l,2) size(az,2)]);	% max size of arguments

if refl
	if size(l,1) == 1
		l = repmat(l,[m,n]);
	end
	s = refl*(1./l(1,:)')*shape;
	s(isinf(s)) = 0;	% because 0-length arrows produced Inf shape elements...
else
	s = repmat(shape,[n,1]);
end

v0 = zeros(n,1);
v1 = ones(n,1);

fx = [s(:,4)*[.5 -.5 -.5] s(:,1)*[-.5 0 .5] s(:,4)*[.5 .5]]';
fy = [v0 v0 (1 - s(:,3)) (1 - s(:,2)) v1 (1 - s(:,2)) (1 - s(:,3)) v0]';

% the beauty of this script: a single patch command to draw all the arrows !
hh = patch(-fx.*l.*cos(az) + fy.*l.*sin(az) + x,fx.*l.*sin(az) + fy.*l.*cos(az) + y,'k',varargin{:});

	
if nargout > 0
	h = hh;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = repval(x,n)

if numel(x) > 1
	x = repmat(x(:)',[n,1]);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [s,v,arg] = checkparam(arg,nam,typ)

switch typ
	case 'isscalar'
		mes = 'scalar value';
	otherwise
		mes = 'value';
end

s = 0;
v = [];
k = find(strcmpi(arg,nam));
if ~isempty(k)
	if strcmp(typ,'option')
		v = 1;
		arg(k) = [];
		s = 1;
	else
		if (k + 1) <= length(arg) & isnumeric(arg{k+1}) & feval(typ,arg{k+1})
			v = arg{k+1};
			arg(k:(k+1)) = [];
			s = 2;
		else
			error('%s option must be followed by a valid %s.',upper(nam),mes)
		end
	end
end

