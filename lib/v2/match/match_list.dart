import 'package:flutter/material.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/v2/border/echelon_border.dart';
import 'package:primea/v2/match/match_summary.dart';
import 'package:primea/v2/match/session_summary.dart';
import 'package:primea/v2/model/account.dart';

class MatchListWidget extends StatelessWidget {
  const MatchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final seasons = InheritedAccount.of(context, AccountAspect.seasons).seasons;
    final matches = InheritedAccount.of(context, AccountAspect.matches).matches;

    return FutureBuilder(
      future: seasons,
      builder: (context, seasonsSnapshot) {
        switch (seasonsSnapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (seasonsSnapshot.hasError) {
              return Center(
                child: Text("Error: ${seasonsSnapshot.error}"),
              );
            }
            break;
          default:
            return Center(
              child: Text(
                  "Error: unknown connection state (${seasonsSnapshot.connectionState})"),
            );
        }
        return StreamBuilder(
          stream: matches.getMatches(seasonsSnapshot.data?.currentSeason),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                break;
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }
                break;
              default:
                return Center(
                  child: Text(
                      "Error: (${seasonsSnapshot.data?.currentSeason})\nunknown connection state (${snapshot.connectionState}) (${matches.getMatches(seasonsSnapshot.data?.currentSeason)})"),
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

            return CustomScrollView(
              slivers: [
                // const SliverToBoxAdapter(
                //   child: NewMatch(chosenParagon: Paragon.aetio),
                // ),
                if (sessions != null)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: sessions.length,
                      (context, index) {
                        final session = sessions.elementAt(index);
                        return Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Container(
                                decoration: ShapeDecoration(
                                  shape: EchelonBorder(
                                    radius: const Radius.circular(8),
                                    left: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      width: 0.5,
                                    ),
                                    right: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: ExpansionTile(
                                  title: SessionSummary(session: session),
                                  children: session
                                      .map(
                                        (match) => Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 720),
                                            child: MatchSummary(
                                              key: ValueKey(match.id),
                                              match: match,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
