import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/util/breakpoint.dart';
import 'package:primea/v2/match/deck_choice.dart';
import 'package:primea/v2/model/account.dart';
import 'package:vector_graphics/vector_graphics.dart';

class ParagonSelector extends StatefulWidget {
  final bool showDecks;
  final Paragon? paragon;
  final Function(Paragon?) onSelectedParagon;
  final Function(Deck?) onSelectedDeck;
  const ParagonSelector({
    super.key,
    required this.showDecks,
    required this.paragon,
    required this.onSelectedParagon,
    required this.onSelectedDeck,
  });

  @override
  State<StatefulWidget> createState() => _ParagonSelectorState();
}

class _ParagonSelectorState extends State<ParagonSelector>
    with TickerProviderStateMixin {
  final parallels = ParallelType.values
      .where((parallel) => parallel != ParallelType.universal);

  late final Map<ParallelType, AnimationController> _controllers =
      Map.fromEntries(parallels.map((parallel) => MapEntry(
          parallel,
          AnimationController(
            duration: const Duration(milliseconds: 200),
            vsync: this,
          ))));

  late final Map<ParallelType, Animation<double>> _opacities =
      Map.fromEntries(parallels.map((parallel) => MapEntry(
          parallel,
          Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _controllers[parallel]!,
              curve: Curves.easeInOut,
            ),
          ))));

  @override
  void dispose() {
    _controllers.forEach((_, value) {
      value.dispose();
    });

    super.dispose();
  }

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

    if (widget.paragon != null) {
      _controllers[widget.paragon!.parallel]?.value = 1;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: Breakpoint.desktop.width),
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverCrossAxisGroup(
            slivers: ParallelType.values
                .where((parallel) => parallel != ParallelType.universal)
                .map(
                  (parallel) => SliverCrossAxisExpanded(
                    flex: 1,
                    sliver: SliverToBoxAdapter(
                      child: InkWell(
                        onHover: (hovering) async {
                          if (hovering) {
                            _controllers[parallel]?.forward();
                          } else if (widget.paragon?.parallel != parallel) {
                            await Future.delayed(
                              Durations.medium1,
                              () {
                                _controllers[parallel]?.reverse();
                              },
                            );
                          }
                        },
                        onTap: () {},
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 232,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                color: parallel.color.withAlpha(100),
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture(
                                  AssetBytesLoader(
                                    "assets/parallel_logos/vec/${parallel.name}.svg.vec",
                                  ),
                                  colorFilter: ColorFilter.mode(
                                    parallel.color,
                                    BlendMode.srcATop,
                                  ),
                                ),
                              ),
                              FadeTransition(
                                opacity: _opacities[parallel]!,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...Paragon.values
                                        .where((paragon) =>
                                            paragon.parallel == parallel &&
                                            paragon.cardID != null)
                                        .map((paragon) {
                                      return Expanded(
                                        flex: widget.paragon == paragon ? 2 : 1,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          child: InkWell(
                                            onTap: () {
                                              if (widget.paragon == paragon) {
                                                widget.onSelectedParagon(null);
                                              } else {
                                                widget
                                                    .onSelectedParagon(paragon);
                                              }
                                              _controllers.forEach(
                                                  (controllerParallel,
                                                      controller) {
                                                if (parallel !=
                                                    controllerParallel) {
                                                  controller.reverse();
                                                }
                                              });
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              fit: StackFit.expand,
                                              children: [
                                                SizedBox.expand(
                                                  child: Image.asset(
                                                    fit: BoxFit.cover,
                                                    alignment:
                                                        Alignment.topCenter,
                                                    color:
                                                        _controllers[parallel]!
                                                                .isDismissed
                                                            ? Colors.black38
                                                            : Colors.black26,
                                                    colorBlendMode:
                                                        BlendMode.srcOver,
                                                    paragon.art!,
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    paragon.title,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (widget.showDecks &&
              MediaQuery.of(context).size.width >= Breakpoint.phone.width)
            SliverCrossAxisGroup(
              slivers: ParallelType.values
                  .where((parallel) => parallel != ParallelType.universal)
                  .map(
                    (parallel) => SliverList.list(
                      children: mappedDecks[parallel]!
                          .map(
                            (deck) => SizedBox(
                              height: 150,
                              child: DeckChoice(
                                deck: deck,
                                onSelect: () => widget.onSelectedDeck(deck),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          if (widget.showDecks &&
              MediaQuery.of(context).size.width < Breakpoint.phone.width)
            ...ParallelType.values
                .where((parallel) => parallel != ParallelType.universal)
                .map(
                  (parallel) => SliverList.list(
                    children: mappedDecks[parallel]!
                        .map(
                          (deck) => SizedBox(
                            height: 150,
                            child: DeckChoice(
                              deck: deck,
                              onSelect: () => widget.onSelectedDeck(deck),
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
