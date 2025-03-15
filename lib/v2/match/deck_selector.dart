import 'package:flutter/material.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/tracker/parallel_avatar.dart';
import 'package:primea/v2/model/account.dart';

class DeckSelector extends StatelessWidget {
  final Function(Paragon) onParagonSelected;
  final Function(Deck) onDeckSelected;
  final String? tooltip;
  final Iterable<Deck>? deckList;

  const DeckSelector({
    super.key,
    required this.onParagonSelected,
    required this.onDeckSelected,
    this.tooltip,
    this.deckList,
  });

  @override
  Widget build(BuildContext context) {
    final mappedDecks =
        InheritedAccount.of(context, AccountAspect.decks).decks.iterable.fold(
      <ParallelType, List<Deck>>{},
      (acc, deck) {
        if (acc[deck.paragon.parallel] == null) {
          acc[deck.paragon.parallel] = [deck];
        } else {
          acc[deck.paragon.parallel]!.add(deck);
        }

        return acc;
      },
    );

    return SizedBox(
      width: 720,
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 44,
              right: 44,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ParallelType.values
                  .where((parallel) => parallel != ParallelType.universal)
                  .map(
                    (parallel) => Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox.square(
                          dimension: 80,
                          child: ParallelAvatar(
                            parallel: parallel,
                            isSelected: false,
                            onSelection: (paragon) {
                              onParagonSelected(paragon);
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          if (mappedDecks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: 44,
                right: 44,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ParallelType.values
                    .where((parallel) => parallel != ParallelType.universal)
                    .map(
                      (parallel) => Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: mappedDecks[parallel]?.map(
                                (mappedDeck) {
                                  return Tooltip(
                                    textAlign: TextAlign.center,
                                    richMessage: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: mappedDeck.name,
                                        ),
                                        const TextSpan(text: '\n'),
                                        TextSpan(
                                          text: Paragon.fromCardID(
                                                  mappedDeck.paragon.id)
                                              .title,
                                        ),
                                        if (mappedDeck.isUniversal)
                                          const TextSpan(text: '\n'),
                                        if (mappedDeck.isUniversal)
                                          TextSpan(
                                            text: ParallelType.universal.title,
                                          ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () => onDeckSelected(mappedDeck),
                                      borderRadius: BorderRadius.zero,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SizedBox(
                                          width: 80,
                                          height: 100,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: LayoutBuilder(
                                                  builder:
                                                      (context, constraints) =>
                                                          Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: mappedDeck
                                                                .isUniversal
                                                            ? ParallelType
                                                                .universal.color
                                                            : mappedDeck.paragon
                                                                .parallel.color
                                                                .withAlpha(200),
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: mappedDeck
                                                                  .isUniversal
                                                              ? ParallelType
                                                                  .universal
                                                                  .color
                                                                  .withAlpha(
                                                                      200)
                                                              : mappedDeck
                                                                  .paragon
                                                                  .parallel
                                                                  .color
                                                                  .withAlpha(
                                                                      200),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      image: DecorationImage(
                                                        alignment:
                                                            Alignment.center,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                          Colors.black
                                                              .withOpacity(0.2),
                                                          BlendMode.darken,
                                                        ),
                                                        image: ResizeImage(
                                                          AssetImage(
                                                            Paragon.fromCardID(
                                                                    mappedDeck
                                                                        .paragon
                                                                        .id)
                                                                .art!,
                                                          ),
                                                          width: constraints
                                                              .maxWidth
                                                              .toInt(),
                                                        ),
                                                        fit: BoxFit.cover,
                                                        filterQuality:
                                                            FilterQuality.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                mappedDeck.name,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                  shadows: [
                                                    const Shadow(
                                                      color: Colors.black,
                                                      offset: Offset(1, 1),
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).toList() ??
                              [
                                Container(
                                  width: 100,
                                )
                              ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
