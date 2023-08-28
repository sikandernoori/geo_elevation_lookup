// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_elevation_lookup/src/geo_elevation_lookup.dart';

void main() {
  group('Geo elevation tests', () {
    final Stopwatch sw = Stopwatch()..start();
    var pwd = Directory.current.path;
    var geoElevationLookup = GeoElevationLookup('$pwd/assets');

    String oplhTest = 'Test elevation of OPLH';
    String oplaTest = 'Test elevation of OPLA';
    String elevationAtSea = 'Test elevation at sea';
    String elevationAtK2 = 'Test elevation at K-2';
    String smallestDatasetFile = 'Test Smallest dataset file';
    String cacheSize = 'Test cache size';

    test(oplhTest, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(31.496059, 74.345742);
      expect(elevation, 210);
      print('$oplhTest took ${sw.elapsedMilliseconds} ms');
    });

    test(oplaTest, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(31.522994, 74.404607);
      expect(elevation, 208);
      print('$oplaTest took ${sw.elapsedMilliseconds} ms');
    });

    test(elevationAtSea, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(29.750562, -43.415430);
      expect(elevation, 0);
      print('$elevationAtSea took ${sw.elapsedMilliseconds} ms');
    });

    test(elevationAtK2, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(35.881866, 76.513240);
      expect(elevation, 8058);
      print('$elevationAtK2 took ${sw.elapsedMilliseconds} ms');
    });

    test(smallestDatasetFile, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(75, 40);
      expect(elevation, -32768);
      print('$smallestDatasetFile took ${sw.elapsedMilliseconds} ms');
    });

    test(cacheSize, () {
      sw.reset();
      expect(geoElevationLookup.tiffImageCache.cacheSize, 3);
      print('$smallestDatasetFile took ${sw.elapsedMilliseconds} ms');
    });
  });
}
