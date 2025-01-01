import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/main.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/model/match/player_rank.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/util/analytics.dart';
import 'package:primea/v2/border/echelon_border.dart';
import 'package:primea/v2/match/deck_viewer.dart';
import 'package:primea/v2/match/labeled_value.dart';
import 'package:primea/v2/match/paragon_selector.dart';
import 'package:primea/v2/model/account.dart';

class NewMatchSliverHeader extends StatefulWidget {
  final double shrinkOffset;
  final bool overlapsContent;

  const NewMatchSliverHeader({
    super.key,
    required this.shrinkOffset,
    required this.overlapsContent,
  });

  @override
  State<StatefulWidget> createState() => _NewMatchSliverHeaderState();
}

class _NewMatchSliverHeaderState extends State<NewMatchSliverHeader> {
  // final parallels = ParallelType.values
  //     .where((parallel) => parallel != ParallelType.universal);

  // late final Map<ParallelType, AnimationController> _controllers =
  //     Map.fromEntries(parallels.map((parallel) => MapEntry(
  //         parallel,
  //         AnimationController(
  //           duration: const Duration(milliseconds: 200),
  //           vsync: this,
  //         ))));

  // late final Map<ParallelType, Animation<double>> _opacities =
  //     Map.fromEntries(parallels.map((parallel) => MapEntry(
  //         parallel,
  //         Tween(
  //           begin: 0.0,
  //           end: 1.0,
  //         ).animate(
  //           CurvedAnimation(
  //             parent: _controllers[parallel]!,
  //             curve: Curves.easeInOut,
  //           ),
  //         ))));

  bool isSaving = false;

  Paragon? chosenParagon;
  Deck? chosenDeck;
  double playerTurnSlider = 0;
  PlayerTurn? playerTurn;
  Paragon? opponentParagon;
  Rank? rank;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mmrController = TextEditingController();
  final TextEditingController _primeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    // _controllers.forEach((_, value) {
    //   value.dispose();
    // });
    _usernameController.dispose();
    _mmrController.dispose();
    _primeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _newMatchEntry(BuildContext context) {
    final session = InheritedSession.of(
      context,
    ).session;
    final decks = InheritedAccount.of(context).decks;
    chosenParagon =
        Paragon.values.byName(session?.user.userMetadata?['paragon']);
    final String? deckId = session?.user.userMetadata?['deck'];
    if (deckId != null) {
      if (context.mounted) {
        decks.findDeck(deckId).then((deck) {
          if (context.mounted) {
            setState(() {
              chosenDeck = deck;
            });
          }
        });
      }
    }

    final season = InheritedAccount.of(context).seasons;
    final matches = InheritedAccount.of(context).matches;
    final currentSeasonMatches = matches.getMatches(season.currentSeason);

    final matchesPlayed = currentSeasonMatches?.where(
      (match) => match.paragon == chosenParagon && match.deck?.id == deckId,
    );

    int wins = 0, losses = 0;
    if (matchesPlayed != null) {
      for (var match in matchesPlayed) {
        if (match.result == MatchResultOption.win) {
          wins++;
        } else if (match.result == MatchResultOption.loss) {
          losses++;
        }
      }
    }
    double winRate = wins / (matchesPlayed?.length ?? 1);

    return Column(
      children: [
        InkWell(
          onTap: () {
            showGeneralDialog(
              context: context,
              transitionDuration: Durations.long4,
              barrierDismissible: true,
              barrierLabel: "Deck Picker",
              pageBuilder: (context, animation1, animation2) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: ParagonSelector(
                    showDecks: true,
                    paragon: null,
                    onSelectedDeck: (deck) {
                      if (deck == null) {
                        return;
                      }
                      setState(() {
                        session?.user.userMetadata?['deck'] = deck.id;
                        session?.user.userMetadata?['paragon'] =
                            Paragon.fromCardID(deck.paragon.id).name;
                        chosenDeck = deck;
                        chosenParagon = Paragon.fromCardID(deck.paragon.id);
                      });
                    },
                    onSelectedParagon: (paragon) {
                      setState(() {
                        chosenParagon = paragon;
                        chosenDeck = null;
                        session?.user.userMetadata?['paragon'] = paragon?.name;
                        session?.user.userMetadata?['deck'] = null;
                      });
                    },
                  ),
                );
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                final slideAnimation = Tween<Offset>(
                  begin: Offset(0, 1),
                  end: Offset(0, 0),
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      0.0,
                      0.65,
                      curve: Curves.easeInOut,
                    ),
                  ),
                );

                final sizeAnimation = Tween<double>(
                  begin: 0.9,
                  end: 1,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      0.65,
                      1,
                      curve: Curves.linear,
                    ),
                  ),
                );

                return SlideTransition(
                  position: slideAnimation,
                  child: ScaleTransition(
                    scale: sizeAnimation,
                    child: child,
                  ),
                );
              },
            );
          },
          child: Row(
            children: [
              if (chosenDeck != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 220,
                    maxHeight: 144,
                  ),
                  child: DeckViewer(
                    deck: chosenDeck!,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 220,
                    maxHeight: 144,
                  ),
                  child: Image.asset(
                    alignment: Alignment.topCenter,
                    fit: BoxFit.cover,
                    chosenParagon!.art!,
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chosenParagon?.title ?? "UNKNOWN",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LabeledValue(
                        label: "GAMES",
                        value: matchesPlayed?.length.toString() ?? "0",
                        borderColor: const Color(0xaadff141),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "VS",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                shadows: [
                  Shadow(
                    color: Theme.of(context).colorScheme.onSurface,
                    offset: const Offset(0, 0),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 8,
            ),
            child: ParagonSelector(
              showDecks: false,
              paragon: opponentParagon,
              onSelectedDeck: (_) {},
              onSelectedParagon: (paragon) {
                setState(() {
                  opponentParagon = paragon;
                });
              },
            ),
            // child: Row(
            //   children: ParallelType.values
            //       .where((parallel) => parallel != ParallelType.universal)
            //       .map(
            //         (parallel) => Expanded(
            //           child: InkWell(
            //             onHover: (hovering) async {
            //               if (hovering) {
            //                 _controllers[parallel]?.forward();
            //               } else if (opponentParagon?.parallel != parallel) {
            //                 await Future.delayed(
            //                   const Duration(milliseconds: 200),
            //                   () {
            //                     _controllers[parallel]?.reverse();
            //                   },
            //                 );
            //               }
            //             },
            //             onTap: () async {
            //               _controllers[parallel]?.forward();
            //               await Future.delayed(
            //                 const Duration(seconds: 6),
            //                 () {
            //                   _controllers[parallel]?.reverse();
            //                 },
            //               );
            //             },
            //             child: Stack(
            //               fit: StackFit.loose,
            //               alignment: Alignment.center,
            //               children: [
            //                 SizedBox.expand(
            //                   child: Container(
            //                     color: parallel.color.withAlpha(100),
            //                     padding: const EdgeInsets.all(8),
            //                     child: SvgPicture(
            //                       AssetBytesLoader(
            //                         "assets/parallel_logos/vec/${parallel.name}.svg.vec",
            //                       ),
            //                       colorFilter: ColorFilter.mode(
            //                         parallel.color,
            //                         BlendMode.srcATop,
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //                 FadeTransition(
            //                   opacity: _opacities[parallel]!,
            //                   child: Column(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       ...Paragon.values
            //                           .where((paragon) =>
            //                               paragon.parallel == parallel &&
            //                               paragon.cardID != null)
            //                           .map((paragon) {
            //                         return Expanded(
            //                           flex: opponentParagon == paragon ? 2 : 1,
            //                           child: AnimatedContainer(
            //                             duration:
            //                                 const Duration(milliseconds: 250),
            //                             child: InkWell(
            //                               onTap: () {
            //                                 setState(() {
            //                                   if (opponentParagon == paragon) {
            //                                     opponentParagon =
            //                                         Paragon.unknown;
            //                                   } else {
            //                                     opponentParagon = paragon;
            //                                   }
            //                                   _controllers.forEach(
            //                                       (parallel, controller) {
            //                                     if (parallel !=
            //                                         opponentParagon!.parallel) {
            //                                       controller.reverse();
            //                                     }
            //                                   });
            //                                 });
            //                               },
            //                               child: Stack(
            //                                 alignment: Alignment.center,
            //                                 fit: StackFit.loose,
            //                                 children: [
            //                                   SizedBox.expand(
            //                                     child: Image.asset(
            //                                       fit: BoxFit.cover,
            //                                       alignment:
            //                                           Alignment.topCenter,
            //                                       color: _controllers[parallel]!
            //                                               .isDismissed
            //                                           ? Colors.black38
            //                                           : Colors.black26,
            //                                       colorBlendMode:
            //                                           BlendMode.srcOver,
            //                                       paragon.art!,
            //                                     ),
            //                                   ),
            //                                   Text(
            //                                     paragon.title,
            //                                     textAlign: TextAlign.center,
            //                                     maxLines: 2,
            //                                   ),
            //                                 ],
            //                               ),
            //                             ),
            //                           ),
            //                         );
            //                       }),
            //                     ],
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       )
            //       .toList(),
            // ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: ShapeDecoration(
            shape: EchelonBorder(
              radius: const Radius.circular(8),
              top: BorderSide(
                width: 1.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              bottom: BorderSide(
                width: 1.0,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: FittedBox(
                  child: TextButton(
                    child: Text(
                      "Going 1st",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () {
                      setState(() {
                        playerTurn = PlayerTurn.going1st;
                        playerTurnSlider = -1;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Slider(
                  value: playerTurnSlider,
                  min: -1,
                  max: 1,
                  activeColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  divisions: 2,
                  thumbColor: playerTurnSlider < 0
                      ? Colors.yellow
                      : playerTurnSlider == 0
                          ? Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                          : Colors.cyan,
                  onChanged: (value) {
                    setState(() {
                      playerTurnSlider = value;
                      if (value == -1) {
                        playerTurn = PlayerTurn.going1st;
                      } else if (value == 0) {
                        playerTurn = null;
                      } else {
                        playerTurn = PlayerTurn.going2nd;
                      }
                    });
                  },
                ),
              ),
              Flexible(
                child: FittedBox(
                  child: TextButton(
                    child: Text(
                      "Going 2nd",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () {
                      setState(() {
                        playerTurn = PlayerTurn.going2nd;
                        playerTurnSlider = 1;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 96),
          child: Flex(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            direction: MediaQuery.of(context).size.width > 350
                ? Axis.horizontal
                : Axis.vertical,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Opponent Username",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: DropdownButton<Rank>(
                  value: rank,
                  hint: const Text('Opponent Rank'),
                  onChanged: (value) {
                    setState(() {
                      if (rank == value) {
                        rank = null;
                      } else {
                        rank = value;
                      }
                    });
                  },
                  items: Rank.values.reversed
                      .map(
                        (rank) => DropdownMenuItem<Rank>(
                          value: rank,
                          child: Text(rank.title),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  child: SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^(-|)\d*'),
                        ),
                      ],
                      autocorrect: false,
                      controller: _mmrController,
                      decoration: const InputDecoration(
                        labelText: '+/- MMR',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  child: SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      autocorrect: false,
                      controller: _primeController,
                      decoration: const InputDecoration(
                        labelText: 'PRIME',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          minLines: 1,
          decoration: const InputDecoration(
            labelText: "Notes",
            border: OutlineInputBorder(),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SegmentedButton<MatchResultOption>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: MatchResultOption.win,
                      label: Text(MatchResultOption.win.tooltip),
                      enabled: chosenParagon != null && playerTurn != null,
                      icon: Icon(
                        MatchResultOption.win.icon,
                        color: MatchResultOption.win.color.withOpacity(
                          chosenParagon != null && playerTurn != null ? 1 : .5,
                        ),
                      ),
                    ),
                    ButtonSegment(
                      value: MatchResultOption.draw,
                      label: Text(MatchResultOption.draw.tooltip),
                      enabled: chosenParagon != null && playerTurn != null,
                      icon: Icon(
                        MatchResultOption.draw.icon,
                        color: MatchResultOption.draw.color.withOpacity(
                          chosenParagon != null && playerTurn != null ? 1 : .5,
                        ),
                      ),
                    ),
                    ButtonSegment(
                      value: MatchResultOption.loss,
                      label: Text(MatchResultOption.loss.tooltip),
                      enabled: chosenParagon != null && playerTurn != null,
                      icon: Icon(
                        MatchResultOption.loss.icon,
                        color: MatchResultOption.loss.color.withOpacity(
                          chosenParagon != null && playerTurn != null ? 1 : .5,
                        ),
                      ),
                    ),
                  ],
                  selected: const {},
                  emptySelectionAllowed: true,
                  multiSelectionEnabled: false,
                  onSelectionChanged: (selection) async {
                    final start = DateTime.now();
                    setState(() {
                      isSaving = true;
                    });
                    await supabase.from(MatchModel.gamesTableName).insert(
                          MatchModel(
                            paragon: chosenParagon!,
                            opponentUsername: _usernameController.text.isEmpty
                                ? null
                                : _usernameController.text,
                            opponentParagon: opponentParagon!,
                            playerTurn: playerTurn!,
                            matchTime: DateTime.now().toUtc(),
                            result: selection.first,
                            opponentRank: rank,
                            mmrDelta: int.tryParse(_mmrController.text),
                            primeEarned: double.tryParse(_primeController.text),
                            deckId: chosenDeck?.id,
                            deck: chosenDeck,
                            notes: _notesController.text.isEmpty
                                ? null
                                : _notesController.text,
                          ),
                        );

                    setState(() {
                      isSaving = false;
                      playerTurnSlider = 0;
                      playerTurn = null;
                      chosenParagon = null;
                      rank = null;
                      _usernameController.clear();
                      _mmrController.clear();
                      _primeController.clear();
                      _notesController.clear();
                    });
                    // _controllers.forEach((parallel, controller) {
                    //   controller.reverse();
                    // });
                    Analytics.instance.trackEvent("createMatch", {
                      "duration":
                          DateTime.now().difference(start).inMilliseconds,
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: EchelonBorder(
          radius: const Radius.circular(8),
          top: BorderSide(
            width: 1.0,
            color: Theme.of(context).colorScheme.primary,
          ),
          bottom: BorderSide(
            width: 1.0,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: isSaving
            ? const FittedBox(
                child: CircularProgressIndicator(),
              )
            : _newMatchEntry(context),
      ),
    );
  }
}
