function z = naninterp2(varargin)
%NANINTERP2 2-D optimized linear interpolation (filling gaps).
%	ZI=NANINTERP2(Z) returns matrix Z with gaps (NaN values) linearly
%	interpolated.
%
%	NANINTERP2(X,Y,Z) uses coordinates X and Y (vectors or matrix
%	consistent in size with matrix Z).
%
%	NANINTERP2 uses Matlab's core function GRIDDATA.
%
%	Note: GRIDDATA may fail with memory issue on huge grids. This simple 
%	function optimizes the interpolation, by reducing the amount of 
%	relevant data (only gap neighbors) before calling GRIDDATA.
%
%	Author: François Beauducel, <beauducel@ipgp.fr>
%	Created: 2013-01-07, Paris (France)
%	Updated: 2016-03-27


%	Copyright (c) 2016, François Beauducel, covered by BSD License.
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
%	     the documentation and/or other materials provided with the 
%	     distribution
%	                           
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
%	IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
%	TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
%	PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
%	OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
%	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
%	LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
%	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
%	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
%	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
%	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if nargin ~= 1 && nargin ~= 3
	error('Wrong number of arguments.')
end

if nargin == 1
	z = varargin{1};
	[x,y] = meshgrid(1:size(z,2),1:size(z,1));
else
	x = varargin{1};
	y = varargin{2};
	z = varargin{3};
	if any(size(x)==1) && any(size(y))==1
		[x,y] = meshgrid(x,y);
	end
	if ~all(size(x)==size(z)) || ~all(size(y)==size(z))
		error('Size of X, Y and Z must be consistent.')
	end
end

% basic principe: build a mask of all surrounding pixels of NaN areas...
% playing with matrix and linear indexing!

sz = size(z);

k = find(isnan(z));
k(k == 1 | k == numel(z)) = []; % removes first and last index (if exist)

if ~isempty(k)
	mask = zeros(sz,'int8');
	k2 = ind90(sz,k); % k2 is linear index in the row order
	% sets to 1 every previous and next index, both in column and row order
	mask([k-1;k+1;ind90(fliplr(sz),[k2-1;k2+1])]) = 1; 
	mask(k) = 0; % removes the novalue index
	kb = find(mask); % keeps only border values
	z(k) = griddata(x(kb),y(kb),z(kb),x(k),y(k));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function k2 = ind90(sz,k)

[i,j] = ind2sub(sz,k);
k2 = sub2ind(fliplr(sz),j,i); % switched i and j: k2 is linear index in row order
