import 'package:flutter/material.dart';
import 'package:primea/v2/match/labeled_value.dart';

class PlayerPanel extends StatefulWidget {
  const PlayerPanel({super.key});

  @override
  State<StatefulWidget> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<PlayerPanel> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: Text(''),
        ),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            padding: EdgeInsets.only(
              left: 36,
              top: 30,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'USER: [UNKNOWN]\n',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        TextSpan(
                          text: 'SEASON: [UNKNOWN]\n',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                Table(
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: LabeledValue(
                              label: 'RANK',
                              value: 'UNRANKED',
                              borderColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        TableCell(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: LabeledValue(
                              label: 'MMR',
                              value: '0',
                              borderColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: LabeledValue(
                              label: "GAMES PLAYED (7D)",
                              value: "49",
                              borderColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        TableCell(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: LabeledValue(
                              label: "GAMES PLAYED (30D)",
                              value: "147",
                              borderColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: LabeledValue(
                              label: "GAMES WON",
                              value: "89",
                              borderColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        TableCell(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: LabeledValue(
                              label: "GAMES LOST",
                              value: "58",
                              borderColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
