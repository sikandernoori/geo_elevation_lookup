import 'package:geo_elevation_lookup/src/cache/tiff_image_cache.dart';
import 'package:geo_elevation_lookup/src/utils/dem_utils.dart';
import 'package:geo_elevation_lookup/src/utils/geo_utils.dart';
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
  static const int dLon = 10;

  /// Latitudinal sepration for each rectangler taken from [GTOPO30].
  static const int dLat = 5;

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
    this.maxCacheSize = 10,
  }) : tiffImageCache = TiffImageCache(maxCacheSize);

  /// Get elevation from latitude and longitude.
  ///
  /// Returns the elevation in meters at the specified [latitude] and [longitude]
  /// using data from the USGS EROS GTOPO30 DEM.
  ///
  /// If the elevation data is not available, 0 is returned.
  int getElevation(double latitude, double longitude) {
    try {
      if (!DEMUtils.checkDEMFolderExist(_demsPath)) throw 'DEM not found at path: $_demsPath';

      var colAbsolute = GeoUtils.longitudeToColumn(longitude);
      var rowAbsolute = GeoUtils.latitudeToRow(latitude);
      var significantLong = GeoUtils.roundToPrevious10th(longitude.floor()).toDouble();
      var colOffset = GeoUtils.longitudeToColumn(significantLong);
      var significantLat = GeoUtils.roundToNext5th(latitude).toDouble();
      var rowOffset = GeoUtils.latitudeToRow(significantLat);

      var index = ((GeoUtils.roundToPrevious10th(longitude.floor()) + (width / 2)) / dLon).floor() +
          (((GeoUtils.roundToPrevious5th(latitude.floor()) + (height / 2)) / dLat) * (height / dLat)).floor();

      if (DEMUtils.checkDEMFileExist(_demsPath, index)) {
        var image = (tiffImageCache.get(index) as Image?) ?? DEMUtils.getDEM('$_demsPath/$index.tiff');

        if (image == null) {
          throw 'Unable to parse file to image';
        } else if (image.data == null) {
          throw 'Empty Image found at path: $_demsPath$index.tiff';
        }

        if (tiffImageCache.get(index) == null) {
          tiffImageCache.put(index, image);
        }

        return image.data!.getPixel(colAbsolute - colOffset, (rowAbsolute - rowOffset).abs()).r.toInt();
      }

      return 0;
    } catch (_) {
      rethrow;
    }
  }
}
