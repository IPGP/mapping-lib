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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{ref} = referenceEllipsoid(@var{code})
## @deftypefnx {Function File} {} @var{ref} = referenceEllipsoid(@var{name})
##
## This function returns a reference ellipsoid object corresponding to the
## specified @var{code} (numerical EPSG). The values of the SemimajorAxis
## and SemiminorAxis properties are in kilometers. The reference
## ellipsoid has five properties: Code, Name, SemimajorAxis, SemiminorAxis
## and Flattening.
##
## The form code can receive a valid EPSG code. 46 codes are currently
## implemented between 7001 and 7053 (except for 7017, 7023, 7026 and
## 7037-7040).
##
## The valid values for name form are as follows: sphere, unitsphere, earth,
## moon, mercury, venus, mars, jupiter, saturn, uranus, neptune and pluto.
##
## @end deftypefn

## Author: Alfredo Foltran <alfoltran@gmail.com>

function ref = referenceEllipsoid(model)
    ELLIPSOIDS.C7001 = {'Airy 1830' 6377563.396 299.3249646};
    ELLIPSOIDS.C7002 = {'Airy Modified 1849' 6377340.189 299.3249646};
    ELLIPSOIDS.C7003 = {'Australian National Spheroid' 6378160 298.25};
    ELLIPSOIDS.C7004 = {'Bessel 1841' 6377397.155 299.1528128};
    ELLIPSOIDS.C7005 = {'Bessel Modified' 6377492.018 299.1528128};
    ELLIPSOIDS.C7006 = {'Bessel Namibia' 6377483.865 299.1528128};
    ELLIPSOIDS.C7007 = {'Clarke 1858' 20926348 294.260676369};
    ELLIPSOIDS.C7008 = {'Clarke 1866' 6378206.4 294.978698213898};
    ELLIPSOIDS.C7009 = {'Clarke 1866 Michigan' 20926631.531 294.978697164674};
    ELLIPSOIDS.C7010 = {'Clarke 1880 (Benoit)' 6378300.789 293.466315538981};
    ELLIPSOIDS.C7011 = {'Clarke 1880 (IGN)' 6378249.2 293.466021293627};
    ELLIPSOIDS.C7012 = {'Clarke 1880 (RGS)' 6378249.145 293.465};
    ELLIPSOIDS.C7013 = {'Clarke 1880 (Arc)' 6378249.145 293.4663077};
    ELLIPSOIDS.C7014 = {'Clarke 1880 (SGA 1922)' 6378249.2 293.46598};
    ELLIPSOIDS.C7015 = {'Everest 1830 (1937 Adjustment)' 6377276.345 300.8017};
    ELLIPSOIDS.C7016 = {'Everest 1830 (1967 Definition)' 6377298.556 300.8017};
    ELLIPSOIDS.C7018 = {'Everest 1830 Modified' 6377304.063 300.8017};
    ELLIPSOIDS.C7019 = {'GRS 1980' 6378137 298.257222101};
    ELLIPSOIDS.C7020 = {'Helmert 1906' 6378200 298.3};
    ELLIPSOIDS.C7021 = {'Indonesian National Spheroid' 6378160 298.247};
    ELLIPSOIDS.C7022 = {'International 1924' 6378388 297};
    ELLIPSOIDS.C7024 = {'Krassowsky 1940' 6378245 298.3};
    ELLIPSOIDS.C7025 = {'NWL 9D' 6378145 298.25};
    ELLIPSOIDS.C7027 = {'Plessis 1817' 6376523 308.64};
    ELLIPSOIDS.C7028 = {'Struve 1860' 6378298.3 294.73};
    ELLIPSOIDS.C7029 = {'War Office' 6378300 296};
    ELLIPSOIDS.C7030 = {'WGS 84' 6378137 298.257223563};
    ELLIPSOIDS.C7031 = {'GEM 10C' 6378137 298.257223563};
    ELLIPSOIDS.C7032 = {'OSU86F' 6378136.2 298.257223563};
    ELLIPSOIDS.C7033 = {'OSU91A' 6378136.3 298.257223563};
    ELLIPSOIDS.C7034 = {'Clarke 1880' 20926202 293.465};
    ELLIPSOIDS.C7035 = {'Sphere' 6371000 Inf};
    ELLIPSOIDS.C7036 = {'GRS 1967' 6378160 298.247167427};
    ELLIPSOIDS.C7041 = {'Average Terrestrial System 1977' 6378135 298.257};
    ELLIPSOIDS.C7042 = {'Everest (1830 Definition)' 20922931.8 300.8017};
    ELLIPSOIDS.C7043 = {'WGS 72' 6378135 298.26};
    ELLIPSOIDS.C7044 = {'Everest 1830 (1962 Definition)' 6377301.243 300.8017255};
    ELLIPSOIDS.C7045 = {'Everest 1830 (1975 Definition)' 6377299.151 300.8017255};
    ELLIPSOIDS.C7046 = {'Bessel Namibia (GLM)' 6377397.155 299.1528128};
    ELLIPSOIDS.C7047 = {'GRS 1980 Authalic Sphere' 6370997 Inf};
    ELLIPSOIDS.C7048 = {'GRS 1980 Authalic Sphere' 6371007 Inf};
    ELLIPSOIDS.C7049 = {'Xian 1980' 6378140 298.257};
    ELLIPSOIDS.C7050 = {'GRS 1967 (SAD69)' 6378160 298.25};
    ELLIPSOIDS.C7051 = {'Danish 1876' 6377019.27 300};
    ELLIPSOIDS.C7052 = {'Clarke 1866 Authalic Sphere' 6370997 Inf};
    ELLIPSOIDS.C7053 = {'Hough 1960' 6378270 297};

    ELLIPSOIDS.Nsphere = {'Sphere' 6371000 Inf 7035};
    ELLIPSOIDS.Nunitsphere = {'Unit Sphere' 1 Inf NaN};
    ELLIPSOIDS.Nearth = {'WGS 84' 6378137 298.257223563 7030};
    ELLIPSOIDS.Nmoon = {'Moon' 1738100 827.666666666702 NaN};
    ELLIPSOIDS.Nmercury = {'Mercury' 2439700 Inf NaN};
    ELLIPSOIDS.Nvenus = {'Venus' 6051800 Inf NaN};
    ELLIPSOIDS.Nmars = {'Mars' 3396200 169.81 NaN};
    ELLIPSOIDS.Njupiter = {'Jupiter' 71492000 15.4144027598103 NaN};
    ELLIPSOIDS.Nsaturn = {'Saturn' 60268000 10.2079945799458 NaN};
    ELLIPSOIDS.Nuranus = {'Uranus' 25559000 43.6160409556314 NaN};
    ELLIPSOIDS.Nneptune = {'Neptune' 24764000 58.5437352245863 NaN};
    ELLIPSOIDS.Npluto = {'Pluto' 1195 Inf NaN};

    if nargin ~= 1
        error("Code or name must be specified!");
    endif

    if isnumeric(model)
        try
            model_values = eval(['ELLIPSOIDS.C' num2str(model)]);
            ref.Code = model;
        catch
            error("Invalid EPSG code!");
        end_try_catch
    else
        try
            model_values = eval(['ELLIPSOIDS.N' num2str(model)]);
            ref.Code = model_values{4};
        catch
            error("Invalid ellipsoid name!");
        end_try_catch
    endif

    ref.Name = model_values{1};
    ref.SemimajorAxis = model_values{2} / 1000;
    ref.SemiminorAxis = ref.SemimajorAxis - ref.SemimajorAxis / model_values{3};
    ref.Flattening = 1 / model_values{3};
endfunction
