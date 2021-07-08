## Copyright (C) 2014 Alfredo Foltran <alfoltran@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{dist} = vincenty(@var{pt1}, @var{pt2})
## @deftypefnx {Function File} {} @var{dist} = vincenty(@var{pt1}, @var{pt2}, @var{ellipsoid})
## @deftypefnx {Function File} {[@var{dist}, @var{az}] = } {vincenty(@var{pt1}, @var{pt2})}
## @deftypefnx {Function File} {[@var{dist}, @var{az}] = } {vincenty(@var{pt1}, @var{pt2}, @var{ellipsoid})}
##
## Calculates the distance (in kilometers) between @var{pt1} and @var{pt2} using the
## formula devised by Thaddeus Vincenty, with an accurate ellipsoidal model of the
## earth (@var{ellipsoid}). The default ellipsoidal model is 'WGS-84', which is the most
## globally accurate model.
##
## @var{pt1} and @var{pt2} are two-column matrices of the form [latitude longitude].
## The units for the input coordinates angles must be degrees.
## @var{ellipsoid} defines the reference ellipsoid to use.
##
## Sample values for @var{ellipsoid} are the following:
##
## @multitable @columnfractions .7 .3
## @headitem Model @tab @var{ellipsoid}
## @item WGS 1984 (default) @tab referenceEllipsoid(7030)
## @item GRS 1980 @tab referenceEllipsoid(7019)
## @item G.B. Airy 1830 @tab referenceEllipsoid(7001)
## @item Internacional 1924 @tab referenceEllipsoid(7022)
## @item Clarke 1880 @tab referenceEllipsoid(7012)
## @item Australian Nat. @tab referenceEllipsoid(7003)
## @end multitable
##
## The sample model values are the following:
##
## @multitable @columnfractions .35 .20 .20 .25
## @headitem Model @tab Major (km) @tab Minor (km) @tab 1 / f
## @item WGS 1984 @tab 6378.137 @tab 6356.7523142 @tab 298.257223563
## @item GRS 1980 @tab 6378.137 @tab 6356.7523141 @tab 298.257222101
## @item G.B. Airy 1830 @tab 6377.563396 @tab 6356.256909 @tab 299.3249646
## @item Internacional 1924 @tab 6378.388 @tab 6356.911946 @tab 297.0
## @item Clarke 1880 @tab 6378.249145 @tab 6356.51486955 @tab 293.465
## @item Australian Nat. @tab 6378.1600 @tab 6356.774719 @tab 298.25
## @end multitable
##
## Usage:
## @example
## >> vincenty([37, -76], [37, -9])
## ans = 5830.081
## >> vincenty([37, -76], [67, -76], referenceEllipsoid(7019))
## ans = 3337.843
## @end example
##
## @seealso{distance,referenceEllipsoid}
## @end deftypefn

## Author: Alfredo Foltran <alfoltran@gmail.com>

function [dist, az] = vincenty(pt1, pt2, ellipsoid)

    if nargin < 3
        ellipsoid = referenceEllipsoid(7030);
    endif

    major = ellipsoid.SemimajorAxis;
    minor = ellipsoid.SemiminorAxis;
    f = ellipsoid.Flattening;

    iter_limit = 20;

    pt1 = deg2rad(pt1);
    pt2 = deg2rad(pt2);

    [lat1 lng1] = deal(pt1(1), pt1(2));
    [lat2 lng2] = deal(pt2(1), pt2(2));

    delta_lng = lng2 - lng1;

    reduced_lat1 = atan((1 - f) * tan(lat1));
    reduced_lat2 = atan((1 - f) * tan(lat2));

    [sin_reduced1 cos_reduced1] = deal(sin(reduced_lat1), cos(reduced_lat1));
    [sin_reduced2 cos_reduced2] = deal(sin(reduced_lat2), cos(reduced_lat2));

    lambda_lng = delta_lng;
    lambda_prime = 2 * pi;

    i = 0;
    while abs(lambda_lng - lambda_prime) > 10e-12 && i <= iter_limit
        i += 1;
        [sin_lambda_lng cos_lambda_lng] = deal(sin(lambda_lng), cos(lambda_lng));
        sin_sigma = sqrt((cos_reduced2 * sin_lambda_lng) ** 2 + (cos_reduced1 * sin_reduced2 - sin_reduced1 * cos_reduced2 * cos_lambda_lng) ** 2);

        if sin_sigma == 0
            dist = 0;
            return;
        endif

        cos_sigma = (sin_reduced1 * sin_reduced2 + cos_reduced1 * cos_reduced2 * cos_lambda_lng);
        sigma = atan2(sin_sigma, cos_sigma);
        sin_alpha = (cos_reduced1 * cos_reduced2 * sin_lambda_lng / sin_sigma);
        cos_sq_alpha = 1 - sin_alpha ** 2;

        if cos_sq_alpha != 0
            cos2_sigma_m = cos_sigma - 2 * (sin_reduced1 * sin_reduced2 / cos_sq_alpha);
        else
            cos2_sigma_m = 0.0; # Equatorial line
        endif

        C = f / 16.0 * cos_sq_alpha * (4 + f * (4 - 3 * cos_sq_alpha));

        lambda_prime = lambda_lng;
        lambda_lng = (delta_lng + (1 - C) * f * sin_alpha * (sigma + C * sin_sigma * (cos2_sigma_m + C * cos_sigma * (-1 + 2 * cos2_sigma_m ** 2))));
    endwhile

    if i > iter_limit
        error("Inverse Vincenty's formulae failed to converge!");
    endif

    u_sq = cos_sq_alpha * (major ** 2 - minor ** 2) / minor ** 2;
    A = 1 + u_sq / 16384.0 * (4096 + u_sq * (-768 + u_sq * (320 - 175 * u_sq)));
    B = u_sq / 1024.0 * (256 + u_sq * (-128 + u_sq * (74 - 47 * u_sq)));
    delta_sigma = (B * sin_sigma * (cos2_sigma_m + B / 4. * (cos_sigma * (-1 + 2 * cos2_sigma_m ** 2) - B / 6. * cos2_sigma_m * (-3 + 4 * sin_sigma ** 2) * (-3 + 4 * cos2_sigma_m ** 2))));
    dist = minor * A * (sigma - delta_sigma);

    if nargout() > 1
        alpha1 = atan2(cos_reduced2 * sin_lambda_lng, cos_reduced1 * sin_reduced2 - sin_reduced1 * cos_reduced2 * cos_lambda_lng);
        alpha2 = atan2(cos_reduced1 * sin_lambda_lng, -sin_reduced1 * cos_reduced2 + cos_reduced1 * sin_reduced2 * cos_lambda_lng);
        az = [rad2deg(alpha1) rad2deg(alpha2)];
    endif
endfunction
