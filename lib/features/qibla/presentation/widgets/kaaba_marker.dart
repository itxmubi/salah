import 'package:flutter/material.dart';

/// A small vector illustration stays sharp in either theme and needs no network.
class KaabaMarker extends StatelessWidget {
  const KaabaMarker({this.size = 38, super.key});
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _KaabaPainter()),
  );
}

class _KaabaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 40);
    final front = Path()
      ..moveTo(4, 10)
      ..lineTo(24, 6)
      ..lineTo(24, 35)
      ..lineTo(4, 31)
      ..close();
    final side = Path()
      ..moveTo(24, 6)
      ..lineTo(36, 11)
      ..lineTo(36, 30)
      ..lineTo(24, 35)
      ..close();
    final top = Path()
      ..moveTo(4, 10)
      ..lineTo(16, 5)
      ..lineTo(36, 11)
      ..lineTo(24, 15)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF171717));
    canvas.drawPath(side, Paint()..color = const Color(0xFF343434));
    canvas.drawPath(top, Paint()..color = const Color(0xFF4B4B4B));
    final band = Path()
      ..moveTo(4, 16)
      ..lineTo(24, 20)
      ..lineTo(36, 16)
      ..lineTo(36, 20)
      ..lineTo(24, 24)
      ..lineTo(4, 20)
      ..close();
    canvas.drawPath(band, Paint()..color = const Color(0xFFE0B85C));
    canvas.drawRect(
      const Rect.fromLTWH(15, 24, 5, 9),
      Paint()..color = const Color(0xFFD2A445),
    );
    canvas.drawPath(
      front,
      Paint()
        ..color = const Color(0xFFE9DBBB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    canvas.drawPath(
      side,
      Paint()
        ..color = const Color(0xFFE9DBBB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  @override
  bool shouldRepaint(_KaabaPainter oldDelegate) => false;
}
