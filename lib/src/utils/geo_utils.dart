class GeoUtils {
  static int longitudeToColumn(double longitude) {
    const double columnsPerDegree = 43200 / 360;
    return (columnsPerDegree * (longitude + 180)).toInt();
  }

  static int latitudeToRow(double latitude) {
    const double rowsPerDegree = 21600 / 180;
    return (rowsPerDegree * (90 - latitude)).toInt();
  }

  // TODO: find a meaningful name
  static int roundToPrevious10th(int value) {
    if (value >= 0) {
      return (value ~/ 10) * 10;
    } else {
      return ((value - 9) ~/ 10) * 10;
    }
  }

  // TODO: find a meaningful name
  static int roundToPrevious5th(int value) {
    if (value >= 0) {
      return (value ~/ 5) * 5;
    } else {
      return ((value - 4) ~/ 5) * 5;
    }
  }

  // TODO: find a meaningful name
  static int roundToNext5th(double value) {
    if (value >= 0) {
      return ((value + 4).ceil() ~/ 5) * 5;
    } else {
      return (value ~/ 5) * 5;
    }
  }
}
