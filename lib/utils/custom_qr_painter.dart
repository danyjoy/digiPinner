import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWithPaddingPainter extends CustomPainter {
  final QrPainter painter;
  final double padding;
  final Color backgroundColor;

  QrWithPaddingPainter({
    required this.painter,
    this.padding = 20,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, paint);

    final offset = Offset(padding, padding);
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    painter.paint(canvas, Size(size.width - 2 * padding, size.height - 2 * padding));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

}
