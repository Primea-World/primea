import 'package:flutter/material.dart';
import 'package:parallel_stats/modal/paragon_picker.dart';
import 'package:parallel_stats/tracker/game_model.dart';
import 'package:parallel_stats/tracker/paragon.dart';
import 'package:parallel_stats/tracker/paragon_avatar.dart';
import 'package:parallel_stats/util/string.dart';

class GameModal extends StatefulWidget {
  const GameModal({super.key});

  @override
  State<StatefulWidget> createState() => GameModalState();
}

class GameModalState extends State<GameModal> {
  Paragon paragon = Paragon.unknown;
  Paragon opponentParagon = Paragon.unknown;
  bool playerOne = true;
  Set<GameResult> result = {GameResult.draw};
  TextEditingController opponentUsernameController = TextEditingController();
  TextEditingController mmrDeltaController = TextEditingController();
  TextEditingController primeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Match Result',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      showDragHandle: false,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return ParagonPicker(
                          onParagonSelected: (paragon) {
                            setState(() {
                              this.paragon = paragon;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    icon: ParagonAvatar(paragon: paragon),
                  ),
                  const Text('VS'),
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      showDragHandle: false,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return ParagonPicker(
                          onParagonSelected: (paragon) {
                            setState(() {
                              opponentParagon = paragon;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    icon: ParagonAvatar(paragon: opponentParagon),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('On the Play'),
                  ),
                  Tooltip(
                    message:
                        playerOne ? 'You play first' : 'Opponent plays first',
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Switch(
                        value: playerOne,
                        onChanged: (value) => setState(() {
                          playerOne = value;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton(
                  emptySelectionAllowed: false,
                  multiSelectionEnabled: false,
                  showSelectedIcon: false,
                  // selectedIcon: const Icon(Icons.check),
                  selected: result,
                  segments: GameResult.values
                      .map(
                        (gameResult) => ButtonSegment(
                          value: gameResult,
                          label: Text(gameResult.tooltip),
                        ),
                      )
                      .toList(),
                  onSelectionChanged: (selection) => setState(() {
                    result = selection;
                  }),
                ),
              ),
              SizedBox(
                width: 500,
                child: ExpansionTile(
                  title: const Text('Advanced Options'),
                  initiallyExpanded: false,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: 250,
                            child: TextField(
                              controller: opponentUsernameController,
                              decoration: const InputDecoration(
                                labelText: 'Opponent Username',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: 50,
                            child: TextField(
                              controller: mmrDeltaController,
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: true,
                                decimal: false,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'MMR',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: 100,
                            child: TextField(
                              controller: primeController,
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: false,
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'PRIME',
                                // suffix: Text("MMR"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 64),
                      ElevatedButton(
                        onPressed: () {
                          final game = GameModel(
                            paragon: paragon,
                            opponentParagon: opponentParagon,
                            playerOne: playerOne,
                            result: result.first,
                            opponentUsername: opponentUsernameController.text,
                            mmrDelta: int.tryParse(mmrDeltaController.text),
                            primeEarned: double.tryParse(primeController.text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Saving game: ${game.paragon.title.toTitleCase()} vs ${game.opponentParagon.title.toTitleCase()}",
                              ),
                            ),
                          );
                          Navigator.of(context).pop(game);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
