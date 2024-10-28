import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class EchelonLogoPainter extends CustomPainter {
  final Color primaryColor;

  EchelonLogoPainter({
    super.repaint,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelWidth = size.width / 44;
    final paint = Paint()..color = primaryColor;

    // <path d="M23.552 3.505 4.998 22H0L22.09 0h6.489l3.554 3.505h-8.582Z" fill="#fff"></path>
    final left = Path()
      ..moveTo(pixelWidth * 23.552, 3.505 * pixelWidth)
      ..lineTo(pixelWidth * 4.998, 22 * pixelWidth)
      ..lineTo(pixelWidth * 0, 22 * pixelWidth)
      ..lineTo(pixelWidth * 22.09, 0 * pixelWidth)
      ..relativeLineTo(pixelWidth * 6.489, 0 * pixelWidth)
      ..relativeLineTo(pixelWidth * 3.554, 3.505 * pixelWidth)
      ..relativeLineTo(pixelWidth * -8.582, 0 * pixelWidth)
      ..close();

    canvas.drawPath(left, paint);

    // <path d="M25.921 9.34 13.221 22H8.237L24.46 5.835h10.036l3.555 3.505h-12.13Z" fill="#fff"></path>
    final center = Path()
      ..moveTo(pixelWidth * 25.921, 9.34 * pixelWidth)
      ..lineTo(pixelWidth * 13.221, 22 * pixelWidth)
      ..lineTo(pixelWidth * 8.237, 22 * pixelWidth)
      ..lineTo(pixelWidth * 24.46, 5.835 * pixelWidth)
      ..relativeLineTo(pixelWidth * 10.036, 0 * pixelWidth)
      ..relativeLineTo(pixelWidth * 3.555, 3.505 * pixelWidth)
      ..relativeLineTo(pixelWidth * -12.13, 0 * pixelWidth)
      ..close();

    canvas.drawPath(center, paint);

    // <path d="M28.291 15.204H44L40.445 11.7H26.831L16.489 22h4.986l6.816-6.796Z" fill="#fff"></path>
    final right = Path()
      ..moveTo(pixelWidth * 28.291, 15.204 * pixelWidth)
      ..lineTo(pixelWidth * 44, 15.204 * pixelWidth)
      ..lineTo(pixelWidth * 40.445, 11.7 * pixelWidth)
      ..lineTo(pixelWidth * 26.831, 11.7 * pixelWidth)
      ..lineTo(pixelWidth * 16.489, 22 * pixelWidth)
      ..relativeLineTo(pixelWidth * 4.986, 0 * pixelWidth)
      ..relativeLineTo(pixelWidth * 6.816, -6.796 * pixelWidth)
      ..close();

    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
