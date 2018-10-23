# Vincenty

## vincenty.m
Calculates the distance (in kilometers) between **point 1** and **point 2** using the
formula devised by Thaddeus Vincenty, with an accurate ellipsoidal model of the
earth. The default ellipsoidal model is **WGS-84**, which is the most globally accurate model.

### Forms

```matlab
dist = vincenty(pt1, pt2)
dist = vincenty(pt1, pt2, ellipsoid)
[dist, az] = vincenty(pt1, pt2)
[dist, az] = vincenty(pt1, pt2, ellipsoid)
```

   `pt1` and `pt2` are two-column matrices of the form `[latitude longitude]`.
   The units for the input coordinates angles must be *degrees*.
   `ellipsoid` defines the reference ellipsoid to use.

Sample values for `ellipsoid` are the following:

* WGS\_84 (default) - referenceEllipsoid(7030)
* GRS\_80 - referenceEllipsoid(7019)
* Airy - referenceEllipsoid(7001)
* Intl - referenceEllipsoid(7022)
* Clarke - referenceEllipsoid(7012)
* GRS - referenceEllipsoid(7003)

The sample values are the following:

| Model              | Major (km)  | Minor (km)    | 1 / f         |
| ------------------ | ----------- | ------------- | ------------- |
| WGS 1984           | 6378.137    | 6356.7523142  | 298.257223563 |
| GRS 1980           | 6378.137    | 6356.7523141  | 298.257222101 |
| G.B. Airy 1830     | 6377.563396 | 6356.256909   | 299.3249646   |
| Internacional 1924 | 6378.388    | 6356.911946   | 297.0         |
| Clarke 1880        | 6378.249145 | 6356.51486955 | 293.465       |
| Australian Nat.    | 6378.1600   | 6356.774719   | 298.25        |

### Example

```matlab
>> vincenty([37, -76], [37, -9])
ans = 5830.081
>> vincenty([37, -76], [67, -76], referenceEllipsoid(7019))
ans = 3337.843
```

## Reference Ellipsoid
This function returns a reference ellipsoid object corresponding to the
specified `code` (numerical EPSG). The values of the `SemimajorAxis`
and `SemiminorAxis` properties are in kilometers. The reference
ellipsoid has five properties: `Code`, `Name`, `SemimajorAxis`, `SemiminorAxis`
and `Flattening`.

The form code can receive a valid EPSG code. 46 codes are currently
implemented between 7001 and 7053 (except for 7017, 7023, 7026 and
7037-7040).

The valid values for name form are as follows: sphere, unitsphere, earth,
moon, mercury, venus, mars, jupiter, saturn, uranus, neptune and pluto.

### Forms

```matlab
ref = referenceEllipsoid(code)
ref = referenceEllipsoid(name)
```

Type `help vincenty` or `help referenceEllipsoid` for syntax, help and examples.
