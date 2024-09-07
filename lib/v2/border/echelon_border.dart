import 'package:flutter/rendering.dart';

class EchelonBorder extends ShapeBorder {
  final BorderSide top;
  final BorderSide bottom;
  final BorderSide left;
  final BorderSide right;
  final Radius radius;

  const EchelonBorder({
    this.top = BorderSide.none,
    this.bottom = BorderSide.none,
    this.left = BorderSide.none,
    this.right = BorderSide.none,
    this.radius = Radius.zero,
  }) : assert(
            ((top != BorderSide.none || bottom != BorderSide.none) &&
                    (left == BorderSide.none && right == BorderSide.none)) ||
                ((top == BorderSide.none && bottom == BorderSide.none) &&
                    (left != BorderSide.none || right != BorderSide.none)),
            "this shape may only have vertical OR horizontal borders set, not both");

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(
        top: (radius.y / 2) + 1,
        bottom: (radius.y / 2) + 1,
        left: (radius.x / 2) + 1,
        right: (radius.x / 2) + 1,
      );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addPolygon(
        [
          rect.topLeft.translate(0, radius.y),
          rect.topLeft.translate(radius.x, 0),
          rect.topRight.translate(-radius.x, 0),
          rect.topRight.translate(0, radius.y),
          rect.bottomRight.translate(0, -radius.y),
          rect.bottomRight.translate(-radius.x, 0),
          rect.bottomLeft.translate(radius.x, 0),
          rect.bottomLeft.translate(0, -radius.y),
        ],
        true,
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addPolygon(
        [
          rect.topLeft.translate(0, radius.y),
          rect.topLeft.translate(radius.x, 0),
          rect.topRight.translate(-radius.x, 0),
          rect.topRight.translate(0, radius.y),
          rect.bottomRight.translate(0, -radius.y),
          rect.bottomRight.translate(-radius.x, 0),
          rect.bottomLeft.translate(radius.x, 0),
          rect.bottomLeft.translate(0, -radius.y),
        ],
        true,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (top != BorderSide.none) {
      final topPaint = top.toPaint();
      canvas.drawLine(
        rect.topLeft.translate(radius.x, 0),
        rect.topRight.translate(-radius.x, 0),
        topPaint,
      );
      canvas.drawLine(
        rect.topLeft.translate(0, radius.y),
        rect.topLeft.translate(radius.x, 0),
        topPaint..strokeWidth = topPaint.strokeWidth * 2,
      );
      canvas.drawLine(
        rect.topRight.translate(0, radius.y),
        rect.topRight.translate(-radius.x, 0),
        topPaint..strokeWidth = topPaint.strokeWidth * 2,
      );
    }
    if (bottom != BorderSide.none) {
      final bottomPaint = bottom.toPaint();
      canvas.drawLine(
        rect.bottomLeft.translate(radius.x, 0),
        rect.bottomRight.translate(-radius.x, 0),
        bottomPaint,
      );
      canvas.drawLine(
        rect.bottomLeft.translate(0, -radius.y),
        rect.bottomLeft.translate(radius.x, 0),
        bottomPaint..strokeWidth = bottomPaint.strokeWidth * 2,
      );
      canvas.drawLine(
        rect.bottomRight.translate(0, -radius.y),
        rect.bottomRight.translate(-radius.x, 0),
        bottomPaint..strokeWidth = bottomPaint.strokeWidth * 2,
      );
    }
    if (left != BorderSide.none) {
      final leftPaint = left.toPaint();
      canvas.drawLine(
        rect.topLeft.translate(0, radius.y),
        rect.bottomLeft.translate(0, -radius.y),
        leftPaint,
      );
      canvas.drawLine(
        rect.topLeft.translate(0, radius.y),
        rect.topLeft.translate(radius.x, 0),
        leftPaint..strokeWidth = leftPaint.strokeWidth * 2,
      );
      canvas.drawLine(
        rect.bottomLeft.translate(0, -radius.y),
        rect.bottomLeft.translate(radius.x, 0),
        leftPaint..strokeWidth = leftPaint.strokeWidth * 2,
      );
    }
    if (right != BorderSide.none) {
      final rightPaint = right.toPaint();
      canvas.drawLine(
        rect.topRight.translate(0, radius.y),
        rect.bottomRight.translate(0, -radius.y),
        rightPaint,
      );
      canvas.drawLine(
        rect.topRight.translate(0, radius.y),
        rect.topRight.translate(-radius.x, 0),
        rightPaint..strokeWidth = rightPaint.strokeWidth * 2,
      );
      canvas.drawLine(
        rect.bottomRight.translate(0, -radius.y),
        rect.bottomRight.translate(-radius.x, 0),
        rightPaint..strokeWidth = rightPaint.strokeWidth * 2,
      );
    }
  }

  @override
  ShapeBorder scale(double t) {
    return EchelonBorder(
        top: top.scale(t),
        bottom: bottom.scale(t),
        right: right.scale(t),
        left: left.scale(t),
        radius: Radius.elliptical(radius.x * t, radius.y * t));
  }
}
