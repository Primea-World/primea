import 'package:flutter/material.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/modal/deck_preview.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/v2/match/labeled_value.dart';
import 'package:primea/v2/model/account.dart';

class DeckPickerSliverHeader extends StatefulWidget {
  const DeckPickerSliverHeader({super.key});

  @override
  State<StatefulWidget> createState() => _DeckPickerSliverHeaderState();
}

class _DeckPickerSliverHeaderState extends State<DeckPickerSliverHeader> {
  @override
  Widget build(BuildContext context) {
    final session = InheritedSession.of(
      context,
    ).session;
    final decks = InheritedAccount.of(context).decks;
    final paragon =
        Paragon.values.byName(session?.user.userMetadata?['paragon']);
    final deckId = session?.user.userMetadata?['deck'];
    final deck = decks.findDeck(deckId);

    final season = InheritedAccount.of(context).seasons;
    final matches = InheritedAccount.of(context).matches;
    final currentSeasonMatches = matches.getMatches(season.currentSeason);

    final matchesPlayed = currentSeasonMatches
        ?.where((match) => match.paragon == paragon && match.deck == deckId);

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            showGeneralDialog(
              context: context,
              transitionDuration: Durations.medium1,
              barrierDismissible: true,
              barrierLabel: "Deck Picker",
              pageBuilder: (context, animation1, animation2) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: GridView.count(
                    crossAxisCount: 4,
                    children: [
                      for (var deck in decks.decks)
                        InkWell(
                          onTap: () {
                            // session?.user.userMetadata?['deck'] = deck.id;
                            // session?.updateUserMetadata();
                            Navigator.of(context).pop();
                          },
                          child: DeckPreview(
                              deck: deck, onUpdate: (_) {}, onDelete: () {}),
                          // child: Column(
                          //   children: [
                          //     AspectRatio(
                          //       aspectRatio: 100 / 120,
                          //       child: Image(
                          //         alignment: Alignment.topCenter.add(
                          //           Alignment(0, 0.25),
                          //         ),
                          //         fit: BoxFit.cover,
                          //         image: AssetImage(
                          //             Paragon.fromCardID(deck.paragon.id).art ??
                          //                 Paragon.unknown.image!),
                          //       ),
                          //     ),
                          //     Text(
                          //       deck.name,
                          //       style: Theme.of(context).textTheme.labelSmall,
                          //     ),
                          //   ],
                          // ),
                        ),
                    ],
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
                      0.5,
                      curve: Curves.easeInOut,
                    ),
                  ),
                );

                final sizeAnimation = Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      0.25,
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
              Container(
                margin: const EdgeInsets.only(right: 8),
                constraints: const BoxConstraints(
                  maxWidth: 120,
                ),
                child: AspectRatio(
                  aspectRatio: 100 / 120,
                  child: Image(
                    alignment: Alignment.topCenter.add(
                      Alignment(0, 0.25),
                    ),
                    fit: BoxFit.cover,
                    image: AssetImage(paragon.art ?? Paragon.unknown.image!),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    paragon.title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  FutureBuilder(
                    future: deck,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isUniversal) {
                          return Chip(
                            labelPadding: EdgeInsets.all(1),
                            label: Text(
                              "UNIVERSAL",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  FutureBuilder(
                    future: deck,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isUniversal) {
                          return Text(
                            "DECK NAME: ${snapshot.data!.name}",
                            style: Theme.of(context).textTheme.labelLarge,
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
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
      ],
    );
  }
}
