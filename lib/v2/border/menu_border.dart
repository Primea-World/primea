import 'package:flutter/rendering.dart';

class MenuBorder extends ShapeBorder {
  final TextStyle textStyle;
  final String text;

  const MenuBorder({
    required this.textStyle,
    required this.text,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(
        Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height - 32),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(
        Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height - 32),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )
      ..layout(maxWidth: rect.width)
      ..paint(
        canvas,
        rect.bottomLeft.translate(0, -10),
      );

    final paint = Paint()..color = textStyle.color!;

    canvas.drawRect(
      Rect.fromLTWH(rect.bottomLeft.dx, rect.bottomLeft.dy, 10, 2.5),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.bottomRight.dx, rect.bottomRight.dy, 10, 2.5),
      paint,
    );

    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomRight,
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return MenuBorder(
      textStyle: textStyle..copyWith(fontSize: textStyle.fontSize! * t),
      text: text,
    );
  }
}
