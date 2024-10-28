import 'package:flutter/rendering.dart';

class LogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;
  final Gradient? backgroundGradient;

  LogoPainter({
    super.repaint,
    required this.primaryColor,
    this.backgroundColor = const Color(0x00000000),
    this.backgroundGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = primaryColor;

    final columnWidth = size.width > 100 ? size.width / 40 : size.width / 40;
    // final columnHeight = size.width / 40;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    if (backgroundGradient != null) {
      backgroundPaint.shader = backgroundGradient!.createShader(
        Rect.fromCenter(
          center: size.center(Offset.zero),
          width: size.width,
          height: size.height,
        ),
      );
    }

    canvas.drawCircle(
      size.center(Offset.zero),
      (size.width / 2) - columnWidth / 4,
      Paint()..color = backgroundColor,
    );

    final centerPath = Path()
      ..moveTo(size.width / 2, columnWidth * 0.5)
      ..relativeLineTo(columnWidth, columnWidth)
      ..relativeLineTo(0, columnWidth * 13)
      ..relativeLineTo(columnWidth, columnWidth)
      ..relativeLineTo(0, columnWidth * 20)
      ..relativeLineTo(-columnWidth * 2, columnWidth * 2)
      ..relativeLineTo(-columnWidth * 2, -columnWidth * 2)
      ..relativeLineTo(0, -columnWidth * 20)
      ..relativeLineTo(columnWidth, -columnWidth)
      ..relativeLineTo(0, -columnWidth * 13)
      ..close();

    canvas.drawPath(centerPath, paint);

    final startOffset = Offset(
      size.width / 2 - columnWidth * 9,
      columnWidth * 37.5,
    );

    final cityScapePath = Path()
      // left side
      ..moveTo(startOffset.dx, startOffset.dy)
      ..relativeLineTo(0, -columnWidth * 14.5)
      ..relativeLineTo(columnWidth * 2, -columnWidth * 2)
      ..relativeLineTo(0, columnWidth * 6)
      ..relativeLineTo(columnWidth * 1, columnWidth * 1)
      ..relativeLineTo(0, -columnWidth * 20)
      ..relativeLineTo(columnWidth * 2, columnWidth * 2)
      ..relativeLineTo(0, columnWidth * 20)
      ..relativeLineTo(columnWidth * 1, columnWidth * 1)
      ..relativeLineTo(0, columnWidth * 5)
      ..relativeLineTo(columnWidth * 3, columnWidth * 3)
      // right side
      ..relativeLineTo(columnWidth * 3, -columnWidth * 3)
      ..relativeLineTo(0, -columnWidth * 5)
      ..relativeLineTo(columnWidth * 1, -columnWidth * 1)
      ..relativeLineTo(0, -columnWidth * 20)
      ..relativeLineTo(columnWidth * 2, -columnWidth * 2)
      ..relativeLineTo(0, columnWidth * 20)
      ..relativeLineTo(columnWidth * 1, -columnWidth * 1)
      ..relativeLineTo(0, -columnWidth * 6)
      ..relativeLineTo(columnWidth * 2, columnWidth * 2)
      ..relativeLineTo(0, columnWidth * 14.5)
      // arc back to start along the outer circle
      ..arcToPoint(
        startOffset,
        radius: Radius.circular(size.width / 2),
      )
      ..close();

    canvas.drawPath(cityScapePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
