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
    String negativeCoords = 'Test Negative coords';
    String nagativeLatitude = 'Test Nagative latitude coords';
    String nagativeLongitude = 'Test Nagative latitude coords';

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
      print('$oplaTest took ${sw.elapsedMicroseconds} ms');
    });

    test(elevationAtSea, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(0, 0);
      expect(elevation, -32768);
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

    test(negativeCoords, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(-23.571332, -66.275315);
      expect(elevation, 4253);
      print('$negativeCoords took ${sw.elapsedMilliseconds} ms');
    });

    test(nagativeLatitude, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(-17.855005, 124.640616);
      expect(elevation, 128);
      print('$nagativeLatitude took ${sw.elapsedMilliseconds} ms');
    });

    test(nagativeLongitude, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(42.064268, -6.580082);
      expect(elevation, 1022);
      print('$nagativeLongitude took ${sw.elapsedMilliseconds} ms');
    });

    test(cacheSize, () {
      sw.reset();
      expect(geoElevationLookup.tiffImageCache.cacheSize, 7);
      print('$smallestDatasetFile took ${sw.elapsedMilliseconds} ms');
    });
  });
}
