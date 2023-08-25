# geo_elevation_lookup

A Dart and Flutter package that provides the ability to retrieve elevation data from geographical coordinates (latitude and longitude).

## Features

- Retrieve elevation data from latitude and longitude.
- Caching mechanism for faster processing.
- ...

## Data Source

This package uses elevation data from the [USGS EROS Digital Elevation Global 30 Arc-Second Elevation (GTOPO30)](https://www.usgs.gov/centers/eros/science/usgs-eros-archive-digital-elevation-global-30-arc-second-elevation-gtopo30) dataset.

## Getting Started

To use this package, add `geo_elevation_lookup` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  geo_elevation_lookup: ^1.0.0  # Use the latest version
```

## Usage
```
import 'package:geo_elevation_lookup/geo_elevation_lookup.dart';

void main() {
  final geoLookup = GeoElevationLookup('/path/to/elevation/dataset');

  final latitude = 31.496059; // Example latitude
  final longitude = 74.345742; // Example longitude

  final elevation = geoLookup.getElevation(latitude, longitude);
  print('Elevation at ($latitude, $longitude): $elevation meters');
}
```

