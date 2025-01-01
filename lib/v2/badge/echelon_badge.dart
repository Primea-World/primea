import 'package:flutter/material.dart';

class EchelonBadge extends StatelessWidget {
  final Widget child;
  final Widget? label;
  final Color? labelColor;

  const EchelonBadge({
    super.key,
    required this.child,
    required this.label,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (label != null)
          Positioned(
            top: 4,
            right: 0,
            child: Container(
              color: labelColor ?? Theme.of(context).colorScheme.errorContainer,
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: label,
            ),
          ),
      ],
    );
  }
}
