import 'package:flutter/material.dart';

class DeckPickerSliverHeader extends StatefulWidget {
  const DeckPickerSliverHeader({super.key});

  @override
  State<StatefulWidget> createState() => _DeckPickerSliverHeaderState();
}

class _DeckPickerSliverHeaderState extends State<DeckPickerSliverHeader> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 120,
          ),
          child: ElevatedButton(
            onPressed: () {},
            child: Text('New Deck'),
          ),
        ),
        Text('Deck Picker'),
      ],
    );
  }
}
