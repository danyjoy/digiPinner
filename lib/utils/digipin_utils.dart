// ignore_for_file: constant_identifier_names

import 'package:digipin/utils/custom_qr_painter.dart';
import 'package:digipin/utils/qr_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

class DigiPinUtils {
  static const List<List<String>> digipinGrid = [
    ['F', 'C', '9', '8'],
    ['J', '3', '2', '7'],
    ['K', '4', '5', '6'],
    ['L', 'M', 'P', 'T'],
  ];

  static const double MIN_LAT = 2.5;
  static const double MAX_LAT = 38.5;
  static const double MIN_LON = 63.5;
  static const double MAX_LON = 99.5;

  static String getDigiPin(double lat, double lon) {
    if (lat < MIN_LAT || lat > MAX_LAT) {
      throw ArgumentError('Latitude out of range');
    }
    if (lon < MIN_LON || lon > MAX_LON) {
      throw ArgumentError('Longitude out of range');
    }

    double minLat = MIN_LAT;
    double maxLat = MAX_LAT;
    double minLon = MIN_LON;
    double maxLon = MAX_LON;

    StringBuffer digiPin = StringBuffer();

    for (int level = 1; level <= 10; level++) {
      double latDiv = (maxLat - minLat) / 4;
      double lonDiv = (maxLon - minLon) / 4;

      int row = 3 - ((lat - minLat) / latDiv).floor();
      int col = ((lon - minLon) / lonDiv).floor();

      row = row.clamp(0, 3);
      col = col.clamp(0, 3);

      digiPin.write(digipinGrid[row][col]);

      if (level == 3 || level == 6) {
        digiPin.write('-');
      }

      // Update bounds
      maxLat = minLat + latDiv * (4 - row);
      minLat = minLat + latDiv * (3 - row);
      minLon = minLon + lonDiv * col;
      maxLon = minLon + lonDiv;
    }

    return digiPin.toString();
  }

  static Map<String, double> getLatLngFromDigiPin(String digiPin) {
    String pin = digiPin.replaceAll('-', '');
    if (pin.length != 10) {
      throw ArgumentError('Invalid DIGIPIN');
    }

    double minLat = MIN_LAT;
    double maxLat = MAX_LAT;
    double minLon = MIN_LON;
    double maxLon = MAX_LON;

    for (int i = 0; i < 10; i++) {
      String char = pin[i];
      int ri = -1, ci = -1;
      bool found = false;

      for (int r = 0; r < 4 && !found; r++) {
        for (int c = 0; c < 4; c++) {
          if (digipinGrid[r][c] == char) {
            ri = r;
            ci = c;
            found = true;
            break;
          }
        }
      }

      if (!found) {
        throw ArgumentError('Invalid character in DIGIPIN');
      }

      double latDiv = (maxLat - minLat) / 4;
      double lonDiv = (maxLon - minLon) / 4;

      double lat1 = maxLat - latDiv * (ri + 1);
      double lat2 = maxLat - latDiv * ri;
      double lon1 = minLon + lonDiv * ci;
      double lon2 = minLon + lonDiv * (ci + 1);

      minLat = lat1;
      maxLat = lat2;
      minLon = lon1;
      maxLon = lon2;
    }

    double centerLat = (minLat + maxLat) / 2;
    double centerLon = (minLon + maxLon) / 2;

    return {
      'latitude': double.parse(centerLat.toStringAsFixed(6)),
      'longitude': double.parse(centerLon.toStringAsFixed(6)),
    };
  }

  static Future<void> shareDigiPin(String digiPin, String? mapsURL) async {
    String message = 'Your DIGIPIN is: $digiPin';
    if (mapsURL != null && mapsURL.isNotEmpty) {
      message += '\nView on Google Maps: $mapsURL';
    }

    // Generate QR code as image
    final qrValidationResult = QrValidator.validate(
      data: mapsURL!,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: ui.Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: ui.Color(0xFF000000),
      ),
      gapless: true,
    );

    final recorder = customPaintToPngBytes(
      painter: QrWithPaddingPainter(painter: painter, padding: 16),
    );

    final picData = await recorder;
    final bytes = picData!.buffer.asUint8List();

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Your DIGIPIN',
        files: [
          XFile.fromData(bytes, name: 'digipin.png', mimeType: 'image/png'),
        ],
      ),
    );
  }

  static String formatDigiPin(String digiPin) {
    String formattedPin = '';

    for (int i = 0; i < digiPin.length; i++) {
      formattedPin += digiPin[i];

      if (i == 2 || i == 5) {
        formattedPin += '-';
      }
    }

    return formattedPin;
  }
}
