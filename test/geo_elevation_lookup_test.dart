// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_elevation_lookup/src/geo_elevation_lookup.dart';
// remove this after adding pathToDems
import 'local.dart';

void main() {
  group('Geo elevation tests', () {
    final Stopwatch sw = Stopwatch()..start();
    var geoElevationLookup = GeoElevationLookup(pathToDems); // replace path to DEMs with your loca path

    String oplhTest = 'Test elevation of OPLH';
    String oplaTest = 'Test elevation of OPLA';
    String elevationAtSea = 'Test elevation at sea';
    String elevationAtK2 = 'Test elevation at K-2';
    String smallestDatasetFile = 'Test Smallest dataset file';
    String cacheSize = 'Test cache size';
    String negativeCoords = 'Test Negative coords';
    String nagativeLatitude = 'Test Nagative latitude coords';
    String nagativeLongitude = 'Test Nagative latitude coords';
    String generateNAndCompare = 'Generate N random lat, long and compare with GDAL';

    test("Sample", () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(66.92, -62.20);
      expect(elevation, 504);
      print('Sample took ${sw.elapsedMilliseconds} ms');
    });

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

      var elevation = await geoElevationLookup.getElevation(0, 0);
      expect(elevation, 0);
      print('$elevationAtSea took ${sw.elapsedMilliseconds} ms');
    });

    test(elevationAtK2, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(35.881866, 76.513240);
      expect(elevation, 8238);
      print('$elevationAtK2 took ${sw.elapsedMilliseconds} ms');
    });

    test(smallestDatasetFile, () async {
      sw.reset();

      var elevation = await geoElevationLookup.getElevation(75, 40);
      expect(elevation, 0);
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
      expect(geoElevationLookup.tiffImageCache.cacheSize, 8);
      print('$smallestDatasetFile took ${sw.elapsedMilliseconds} ms');
    });

    List<List<double>> generateRandomLatLongs(int count) {
      Random random = Random();
      List<List<double>> latLongs = [];

      for (int i = 0; i < count; i++) {
        double latitude = -90 + random.nextDouble() * 180;
        double longitude = -180 + random.nextDouble() * 360;

        latitude = double.parse(latitude.toStringAsFixed(2));
        longitude = double.parse(longitude.toStringAsFixed(2));

        latLongs.add([latitude, longitude]);
      }

      return latLongs;
    }

    Future<String> executeCommand(double lat, double long) async {
      String command = 'gdallocationinfo';
      // replace `pathToGTOPO30File` with your loca GTOPO30 file path
      List<String> arguments = ['-geoloc', pathToGTOPO30File, long.toString(), lat.toString()];
      ProcessResult result = await Process.run(command, arguments);
      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        print('Command failed with exit code ${result.exitCode}');
        print('Error message: ${result.stderr}');
        return '';
      }
    }

    int extractElevationValue(String commandOutput) {
      List<String> lines = commandOutput.split('\n');
      String valueLine = lines.firstWhere((line) => line.contains('Value:'), orElse: () => '');
      int elevationValue = int.tryParse(valueLine.split(':').last.trim()) ?? 0;
      return elevationValue;
    }

    test(generateNAndCompare, () async {
      sw.reset();
      final latLongs = generateRandomLatLongs(1000);
      for (var latLong in latLongs) {
        var e1 = await geoElevationLookup.getElevation(latLong[0], latLong[1]);
        String commandOutput = await executeCommand(latLong[0], latLong[1]);
        int e2 = extractElevationValue(commandOutput);
        if (e2 == -32768) e2 = 0;
        expect(e1, e2);
        print(['Success', latLong[0], latLong[1], e1, e2]);
      }

      print('$generateNAndCompare took ${sw.elapsedMilliseconds} ms');
    });
  });
}
