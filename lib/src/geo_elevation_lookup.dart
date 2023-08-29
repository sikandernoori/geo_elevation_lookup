import 'dart:io';

import 'package:geo_elevation_lookup/src/cache/tiff_image_cache.dart';
import 'package:image/image.dart';

/// A class that provides elevation data lookup based on geographic coordinates.
class GeoElevationLookup {
  /// Path of the elevation dataset.
  ///
  /// This should point to the directory containing the elevation data tiles.
  /// Each tile represents elevation data for a specific geographical area.
  ///
  /// Example:
  /// ```dart
  /// '/path/to/elevation/dataset';
  /// ```
  final String _demsPath;

  /// Longitudinal sepration for each rectangler taken from [GTOPO30].
  static const int dLon = 4;

  /// Latitudinal sepration for each rectangler taken from [GTOPO30].
  static const int dLat = 2;

  /// Height of [GTOPO30] tiff file.
  static const int height = 180;

  /// Width of [GTOPO30] tiff file.
  static const int width = 360;

  /// Cached tiff images
  TiffImageCache tiffImageCache;

  /// Enable caching to avoid reloading image in single session for faster processing.
  ///
  /// Default: true
  final bool enableCaching;

  /// Max number of images allowed for caching.
  ///
  /// Default: 10.
  final int maxCacheSize;

  GeoElevationLookup(
    this._demsPath, {
    this.enableCaching = true,
    this.maxCacheSize = 100,
  }) : tiffImageCache = TiffImageCache(maxCacheSize) {
    if (!(Directory(_demsPath).existsSync())) throw 'DEM not found at path: $_demsPath';
  }

  /// Get elevation from latitude and longitude.
  ///
  /// Returns the elevation in meters at the specified [latitude] and [longitude]
  /// using data from the USGS EROS GTOPO30 DEM.
  ///
  /// If the elevation data is not available, 0 is returned.
  Future<int> getElevation(double latitude, double longitude) async {
    try {
      var colAbsolute = longitudeToColumn(longitude);
      var rowAbsolute = latitudeToRow(latitude);
      var minLong = roundToPrevious4th(longitude.floor()).toDouble();
      var colOffset = longitudeToColumn(minLong);
      var maxLat = roundToNext2nd(latitude).toDouble();
      var rowOffset = latitudeToRow(maxLat);

      var index = ((roundToPrevious4th(longitude.floor()) + (width / 2)) / dLon).floor() +
          (((roundToPrevious2nd(latitude.floor()) + (height / 2)) / dLat) * (height / dLat)).floor();

      if (await File('$_demsPath/$index.tiff').exists()) {
        var tiffFile = await File('$_demsPath/$index.tiff').readAsBytes();
        var image = (tiffImageCache.get(index) as Image?) ?? TiffDecoder().decode(tiffFile);
        if (image == null) {
          throw 'Unable to parse file to image';
        } else if (image.data == null) {
          throw 'Empty Image found at path: $_demsPath$index.tiff';
        }

        if (tiffImageCache.get(index) == null) {
          tiffImageCache.put(index, image);
        }

        double col = (colAbsolute - colOffset);
        if (col < 21600) {
          col = col.floor().toDouble();
        } else {
          col = col.round().toDouble();
        }

        double row = (rowAbsolute - rowOffset).abs();
        if (row < 10800) {
          row = row.floor().toDouble();
        } else {
          row = row.round().toDouble();
        }

        var e1 = image.data!.getPixel(col.toInt(), row.toInt()).r.toInt();
        if (e1 == -32768) {
          e1 = 0;
        }

        return e1;
      }

      return 0;
    } catch (_) {
      rethrow;
    }
  }

  static double longitudeToColumn(double longitude) {
    const double columnsPerDegree = 43200 / 360.000019;
    return (columnsPerDegree * (longitude + (360.000019 / 2)));
  }

  static double latitudeToRow(double latitude) {
    const double rowsPerDegree = 21600 / 180.00001;
    return (rowsPerDegree * ((180.00001 / 2) - latitude));
  }

  // TODO: find a meaningful name
  static int roundToPrevious4th(int value) {
    if (value >= 0) {
      return (value ~/ dLon) * dLon;
    } else {
      return ((value - (dLon - 1)) ~/ dLon) * dLon;
    }
  }

  // TODO: find a meaningful name
  static int roundToPrevious2nd(int value) {
    if (value >= 0) {
      return (value ~/ dLat) * dLat;
    } else {
      return ((value - (dLat - 1)) ~/ dLat) * dLat;
    }
  }

  // TODO: find a meaningful name
  static int roundToNext2nd(double value) {
    if (value >= 0) {
      return ((value + (dLat - 1)).ceil() ~/ dLat) * dLat;
    } else {
      return (value ~/ dLat) * dLat;
    }
  }
}
