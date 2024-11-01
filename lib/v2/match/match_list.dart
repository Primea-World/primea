import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/v2/border/echelon_border.dart';
import 'package:primea/v2/match/deck_picker_sliver_delegate.dart';
import 'package:primea/v2/match/match_summary.dart';
import 'package:primea/v2/match/new_match_sliver_delegate.dart';
import 'package:primea/v2/match/session_summary.dart';
import 'package:primea/v2/model/account.dart';

class MatchListWidget extends StatefulWidget {
  const MatchListWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MatchListWidgetState();
}

class _MatchListWidgetState extends State<MatchListWidget> {
  final List<GlobalKey<SliverAnimatedListState>> _listKeys = [];
  final List<bool> _expanded = [];

  final maxExtent = 720.0;

  @override
  Widget build(BuildContext context) {
    final seasons = InheritedAccount.of(context, AccountAspect.seasons).seasons;
    final matches = InheritedAccount.of(context, AccountAspect.matches).matches;

    return FutureBuilder(
      future: matches.fetchMatchesForSeason(seasons.currentSeason),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                child: Text("Matches Error: ${snapshot.error}"),
              );
            }
            break;
          case ConnectionState.none:
            return const Center(child: CircularProgressIndicator());
          default:
            return Center(
              child: Text(
                  "Error: unknown connection state (${snapshot.connectionState}) (${matches.fetchMatchesForSeason(seasons.currentSeason)})"),
            );
        }

        final sessions = snapshot.data?.fold(
          <List<MatchModel>>[],
          (acc, match) {
            if (acc.isEmpty) {
              acc.add([match]);
            } else if (match.matchTime.isAfter(
              acc.last.last.matchTime.subtract(
                const Duration(hours: 4),
              ),
            )) {
              acc.last.add(match);
            } else {
              acc.add([match]);
            }
            return acc;
          },
        );

        if (_listKeys.length != sessions?.length) {
          // re-create the animated list states while preserving the old keys
          // reversing the old keys allows us to keep the same key for the same session
          // while adding new keys for new sessions at what becomes the beginning of the list

          // TODO: this is a bit of a hack, doesn't work well either

          _expanded.clear();
          _expanded.addAll(
            List.generate(
                sessions?.length ?? 0,
                (index) => _expanded.length > index
                    ? _expanded.elementAt(index)
                    : false),
          );

          _listKeys.clear();
          _listKeys.addAll(
            List.generate(
              sessions?.length ?? 0,
              (index) {
                final session = sessions!.elementAt(index);
                final entry = GlobalKey<SliverAnimatedListState>();
                print(session.length);
                if (_expanded.elementAt(index)) {
                  entry.currentState?.insertAllItems(
                    0,
                    session.length,
                    duration: const Duration(milliseconds: 150),
                  );
                }
                return entry;
              },
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: DeckPickerSliverDelegate(),
            ),
            SliverPersistentHeader(
              delegate: NewMatchSliverDelegate(),
            ),
            if (sessions != null)
              ...sessions.indexed.map(
                (entry) {
                  final index = entry.$1;
                  final session = entry.$2;
                  return SliverCrossAxisGroup(
                    slivers: [
                      if (MediaQuery.of(context).size.width > maxExtent + 96)
                        SliverCrossAxisExpanded(
                          flex: 1,
                          sliver: SliverToBoxAdapter(child: Container()),
                        ),
                      SliverConstrainedCrossAxis(
                        maxExtent: maxExtent,
                        sliver: SliverPadding(
                          padding: const EdgeInsets.all(8),
                          sliver: DecoratedSliver(
                            decoration: ShapeDecoration(
                              shape: EchelonBorder(
                                radius: const Radius.circular(8),
                                left: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 0.5,
                                ),
                                right: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            sliver: SliverMainAxisGroup(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: SessionSummary(
                                      key: ValueKey(session.first.id),
                                      session: session,
                                      onExpansionChanged: (isExpanded) {
                                        if (isExpanded) {
                                          _listKeys
                                              .elementAt(index)
                                              .currentState
                                              ?.insertAllItems(
                                                0,
                                                session.length,
                                                duration: const Duration(
                                                  milliseconds: 150,
                                                ),
                                              );
                                        } else {
                                          for (var i = 0;
                                              i < session.length;
                                              i++) {
                                            _listKeys
                                                .elementAt(index)
                                                .currentState
                                                ?.removeItem(
                                              0,
                                              (context, animation) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: SizeTransition(
                                                    sizeFactor: animation,
                                                    child: MatchSummary(
                                                      match:
                                                          session.elementAt(i),
                                                    ),
                                                  ),
                                                );
                                              },
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SliverAnimatedList(
                                  key: _listKeys.elementAt(index),
                                  initialItemCount: 0,
                                  itemBuilder: (context, index, animation) {
                                    final match = session.elementAt(index);
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  onPressed: () {},
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                  ),
                                                  color: Colors.red,
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  onPressed: () async {
                                                    await supabase
                                                        .from(MatchModel
                                                            .gamesTableName)
                                                        .delete()
                                                        .eq('id', match.id!);
                                                    _listKeys
                                                        .elementAt(index)
                                                        .currentState
                                                        ?.removeItem(
                                                      index,
                                                      (context, animation) {
                                                        return FadeTransition(
                                                          opacity: animation,
                                                          child: SizeTransition(
                                                            sizeFactor:
                                                                animation,
                                                            child: MatchSummary(
                                                              match: match,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      duration: const Duration(
                                                        milliseconds: 150,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: MatchSummary(
                                                key: ValueKey(match.id),
                                                match: match,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (MediaQuery.of(context).size.width > maxExtent + 96)
                        SliverCrossAxisExpanded(
                          flex: 1,
                          sliver: SliverToBoxAdapter(child: Container()),
                        ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
