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

### Example App to generate tiffs

```
import 'dart:io';

// ignore: constant_identifier_names
const DEM_PATH = 'path/to/GTOPO30.tif';

Future<bool> divideTiff(
    String index, int x, int y, int width, int height) async {
  final gdalCommand = [
    '-co',
    'compress=lzw',
    '-of',
    'GTiff',
    '-srcwin',
    x.toString(),
    y.toString(),
    width.toString(),
    height.toString(), //  <xoff> <yoff> <xsize> <ysize>
    DEM_PATH,
    '$index.tiff',
  ];

  try {
    final processResult = await Process.run('gdal_translate', gdalCommand,
        workingDirectory: './lib/DEMs/');
    if (processResult.exitCode == 0) {
      // Successfully file created
      return true;
    } else {
      final error = processResult.stderr;
      print('Error: $error');
      return false;
    }
  } catch (error) {
    print('Error: $error');
    return false;
  }
}

Future<void> main() async {
  Stopwatch sw1 = Stopwatch()..start();
  int index = 0;

  for (int x = 0; x < 43200; x = x + 480) {
    for (int y = 0; y < 21600; y = y + 240) {
      await divideTiff('${x}_$y', x, y, 480, 240);
      index++;
      print(index);
    }
  }
  print('Total tiffs: $index');
  print('Took: ${(sw1.elapsedMilliseconds / 1000) / 60} seconds');
}
```
