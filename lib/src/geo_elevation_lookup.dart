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

  /// size of each pixel.
  static const double pixelSize = 0.008333333767951;

  /// starting point of longitude
  static const double originX = -180.000001017469913;

  /// starting point of latitude
  static const double originY = 90.000008840579540;

  /// Width of Tiff
  static const int imageWidth = 480;

  /// Height of Tiff
  static const int imageHeight = 240;

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
      List<int> pixelCoords = latLongToXY(longitude, latitude);

      var xAbsolute = pixelCoords[0];
      var yAbsolute = pixelCoords[1];

      var tiffStartX = getTiffStartX(xAbsolute);
      var tiffStartY = getTiffStartY(yAbsolute).abs();

      var tiffEndX = tiffStartX + imageWidth;
      var tiffEndY = tiffStartY + imageHeight;

      var fileName = '${tiffStartX}_$tiffStartY';

      var xBefore = xAbsolute.toInt() - tiffStartX;
      var yBefore = yAbsolute.toInt() - tiffStartY;

      int x, y = 0;

      if ((xAbsolute.floor() - xBefore) + imageWidth == tiffEndX) {
        x = xAbsolute.floor() - tiffStartX;
      } else {
        x = xAbsolute.ceil() - tiffStartX;
      }

      if ((yAbsolute.floor() - yBefore) + imageHeight == tiffEndY) {
        y = yAbsolute.floor() - tiffStartY;
      } else {
        y = yAbsolute.ceil() - tiffStartY;
      }

      if (await File('$_demsPath/$fileName.tiff').exists()) {
        var tiffFile = await File('$_demsPath/$fileName.tiff').readAsBytes();
        var image = (tiffImageCache.get(fileName) as Image?) ?? TiffDecoder().decode(tiffFile);
        if (image == null) {
          throw 'Unable to parse file to image';
        } else if (image.data == null) {
          throw 'Empty Image found at path: $_demsPath$fileName.tiff';
        }

        if (tiffImageCache.get(fileName) == null) {
          tiffImageCache.put(fileName, image);
        }

        var elevation = image.data!.getPixel(x, y).r.toInt();
        if (elevation == -32768) return 0;

        return elevation;
      }

      return 0;
    } catch (_) {
      rethrow;
    }
  }

  /// Get elevation synchronously from latitude and longitude.
  ///
  /// Returns the elevation in meters at the specified [latitude] and [longitude]
  /// using data from the USGS EROS GTOPO30 DEM.
  ///
  /// If the elevation data is not available, 0 is returned.
  int getElevationSync(double latitude, double longitude) {
    try {
      List<int> pixelCoords = latLongToXY(longitude, latitude);

      var xAbsolute = pixelCoords[0];
      var yAbsolute = pixelCoords[1];

      var tiffStartX = getTiffStartX(xAbsolute);
      var tiffStartY = getTiffStartY(yAbsolute).abs();

      var tiffEndX = tiffStartX + imageWidth;
      var tiffEndY = tiffStartY + imageHeight;

      var fileName = '${tiffStartX}_$tiffStartY';

      var xBefore = xAbsolute.toInt() - tiffStartX;
      var yBefore = yAbsolute.toInt() - tiffStartY;

      int x, y = 0;

      if ((xAbsolute.floor() - xBefore) + imageWidth == tiffEndX) {
        x = xAbsolute.floor() - tiffStartX;
      } else {
        x = xAbsolute.ceil() - tiffStartX;
      }

      if ((yAbsolute.floor() - yBefore) + imageHeight == tiffEndY) {
        y = yAbsolute.floor() - tiffStartY;
      } else {
        y = yAbsolute.ceil() - tiffStartY;
      }

      if (File('$_demsPath/$fileName.tiff').existsSync()) {
        var tiffFile = File('$_demsPath/$fileName.tiff').readAsBytesSync();
        var image = (tiffImageCache.get(fileName) as Image?) ?? TiffDecoder().decode(tiffFile);
        if (image == null) {
          throw 'Unable to parse file to image';
        } else if (image.data == null) {
          throw 'Empty Image found at path: $_demsPath$fileName.tiff';
        }

        if (tiffImageCache.get(fileName) == null) {
          tiffImageCache.put(fileName, image);
        }

        var elevation = image.data!.getPixel(x, y).r.toInt();
        if (elevation == -32768) return 0;

        return elevation;
      }

      return 0;
    } catch (_) {
      rethrow;
    }
  }

  int getTiffStartX(int col) => (col ~/ imageWidth) * imageWidth;

  int getTiffStartY(int row) => (row ~/ imageHeight) * imageHeight;

  int xToCol(double x) => (x - originX) ~/ pixelSize;

  int yToRow(double y) => (y - originY) ~/ pixelSize;

  List<int> latLongToXY(double longitude, double latitude) {
    double adjustedLongitude = longitude - originX;
    double adjustedLatitude = latitude - originY;

    double x = originX + adjustedLongitude;

    double y = originY + adjustedLatitude;

    int col = xToCol(x);
    int row = yToRow(y).abs();

    return [col, row];
  }
}
