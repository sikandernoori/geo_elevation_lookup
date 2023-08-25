import 'dart:io';

import 'package:image/image.dart';

class DEMUtils {
  static Image? getDEM(String path) => TiffDecoder().decode(File(path).readAsBytesSync());

  static bool checkDEMFileExist(String dataSetPath, int index) => File('$dataSetPath/$index.tiff').existsSync();

  static bool checkDEMFolderExist(String demsPath) => Directory(demsPath).existsSync();
}
