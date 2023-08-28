// ignore_for_file: avoid_print

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:example/widgets/custom_button.dart';
import 'package:example/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:geo_elevation_lookup/geo_elevation_lookup.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MaterialApp(home: ExampleApp()));

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  ExampleAppState createState() => ExampleAppState();
}

class ExampleAppState extends State<ExampleApp> {
  final String fileUrl = 'https://github.com/sikandernoori/elevation_extractor/raw/master/lib/DEMs.zip?download=';
  late int totalBytes;
  late int receivedBytes;
  final ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  final String zipFileName = 'DEMs.zip';
  late http.StreamedResponse _response;
  List<int> _bytes = [];
  GeoElevationLookup? geoElevationLookup;

  bool downloadDEMsEnabled = true;
  bool unzipDEMsEnabled = true;

  TextEditingController latitudeController = TextEditingController(text: '31.496059');
  TextEditingController longitudeController = TextEditingController(text: '74.345742');
  TextEditingController elevationController = TextEditingController();

  Future<void> _downloadDEMs() async {
    setState(() => downloadDEMsEnabled = false);
    totalBytes = 0;
    receivedBytes = 0;
    _bytes = [];
    progressNotifier.value = 0;
    _response = await http.Client().send(http.Request('GET', Uri.parse(fileUrl)));
    totalBytes = _response.contentLength ?? 0;

    _response.stream.listen((value) {
      _bytes.addAll(value);
      receivedBytes += value.length;
      progressNotifier.value = receivedBytes / totalBytes;
      print(receivedBytes / totalBytes);
    }).onDone(() async {
      final file = File('${(await getApplicationDocumentsDirectory()).path}/$zipFileName');
      await file.writeAsBytes(_bytes);
      showMessage('DEMs downloaded successfully !');
      setState(() => downloadDEMsEnabled = true);
    });
  }

  Future<void> _unzipFile() async {
    setState(() => unzipDEMsEnabled = false);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final extractionPath = appDir.path;
      final bytes = File('${appDir.path}/$zipFileName').readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filePath = '$extractionPath/${file.name}';
        if (file.isFile) {
          print(file.name);
          final data = file.content as List<int>;
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        }
      }

      showMessage('DEMs uncompressed successfully');
    } catch (e) {
      print('Error: $e');
      showMessage('DEMs uncompressed Error: $e');
    }
    setState(() => unzipDEMsEnabled = true);
  }

  Future<void> _clearLocalData() async {
    try {
      final appDir = (await getApplicationDocumentsDirectory()).listSync();

      for (var dir in appDir) {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          print('Folder deleted at path: ${dir.path}');
        } else {
          print('Folder does not exist at parh: ${dir.path}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _getElevation() async {
    try {
      geoElevationLookup ??= GeoElevationLookup(await getDEMsPath());
      final lat = double.parse(latitudeController.text);
      final lon = double.parse(longitudeController.text);
      final elevation = await geoElevationLookup?.getElevation(lat, lon);
      setState(() => elevationController.text = elevation.toString());
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future<String> getDEMsPath() async => '${(await getApplicationDocumentsDirectory()).path}/DEMs';

  void showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example app')),
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              CustomButton(text: 'Download DEMs', onPressed: _downloadDEMs, enabled: downloadDEMsEnabled),
              CustomButton(text: 'Unzip DEMs', onPressed: _unzipFile, enabled: unzipDEMsEnabled),
              CustomButton(
                text: 'Print All folders',
                onPressed: () async {
                  final directory = await getApplicationDocumentsDirectory();
                  var dirs = directory.listSync();
                  for (var dir in dirs) {
                    print(dir.path);
                  }
                },
              ),
              CustomButton(text: 'Clear local data', onPressed: _clearLocalData),
              ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (context, value, child) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: value, minHeight: 8, backgroundColor: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          progressNotifier.value != 1
                              ? 'Progress: ${(progressNotifier.value * 100).toStringAsFixed(1)}%'
                              : 'DEMs successfully downloaded !',
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              CustomTextField(label: 'Enter latitude', controller: latitudeController),
              const SizedBox(height: 10),
              CustomTextField(label: 'Enter longitude', controller: longitudeController),
              const SizedBox(height: 10),
              CustomTextField(label: 'Elevation (meters)', controller: elevationController, enabled: false),
              const SizedBox(height: 10),
              CustomButton(text: 'Get elevation', onPressed: _getElevation),
            ],
          ),
        ),
      ),
    );
  }
}
