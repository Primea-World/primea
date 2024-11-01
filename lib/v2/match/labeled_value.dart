import 'package:flutter/material.dart';

class LabeledValue extends StatelessWidget {
  final String label;
  final String value;
  final Color borderColor;

  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    required this.borderColor,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 120,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              style: labelStyle ?? Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.start,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: valueStyle ??
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontVariations: [const FontVariation('wght', 600)]),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
