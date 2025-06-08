import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<Uint8List?> customPaintToPngBytes({
  required CustomPainter painter,
  Size size = const Size(700, 700),
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Offset.zero & size);

  painter.paint(canvas, size); // Render your painter

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData?.buffer.asUint8List();
}
