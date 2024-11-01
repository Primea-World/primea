import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:primea/model/season/season.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/util/breakpoint.dart';

class ParagonStats {
  final Paragon paragon;
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;

  ParagonStats({
    required this.paragon,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gamesLost,
  });

  ParagonStats.fromJson(Map<String, dynamic> json)
      : paragon = Paragon.values.byName(json['paragon']),
        gamesPlayed = json['total_count'],
        gamesWon = json['win_count'],
        gamesLost = json['loss_count'];

  @override
  String toString() {
    return 'ParagonStats{paragon: $paragon, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, gamesLost: $gamesLost}';
  }
}

class ParagonInsights extends StatefulWidget {
  final Season season;

  const ParagonInsights({
    super.key,
    required this.season,
  });

  @override
  State<StatefulWidget> createState() => _ParagonInsightsState();
}

class _ParagonInsightsState extends State<ParagonInsights> {
  final _paragons = Paragon.values.where(
      (paragon) => paragon.title.isNotEmpty && paragon != Paragon.unknown);

  late final Future<Iterable<ParagonStats>> _paragonStats = supabase
      .rpc<List<Map<String, dynamic>>>('get_paragon_match_count',
          params: {'season_param': widget.season.id})
      .order('total_count')
      .then((values) => values.map(ParagonStats.fromJson));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _paragonStats,
        builder: (context, snapshot) {
          Iterable<ParagonStats> stats = [];
          if (snapshot.hasData) {
            stats = snapshot.data!;
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: stats.isEmpty ? _paragons.length : stats.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              Paragon paragon = _paragons.elementAt(index);
              int gamesPlayed = 0, gamesWon = 0, gamesLost = 0;
              if (stats.isNotEmpty) {
                final element = stats.elementAt(index);
                paragon = Paragon.values.byName(element.paragon.name);
                gamesPlayed = element.gamesPlayed;
                gamesWon = element.gamesWon;
                gamesLost = element.gamesLost;
              }

              return Center(
                child: Container(
                  margin: EdgeInsets.all(8),
                  constraints:
                      BoxConstraints(maxWidth: Breakpoint.tablet.width),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 150),
                        child: AspectRatio(
                          aspectRatio: 100 / 120,
                          child: Image(
                            alignment: Alignment.topCenter,
                            fit: BoxFit.cover,
                            image: AssetImage(paragon.art ?? paragon.image!),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              paragon.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              'Games Played: $gamesPlayed\n'
                              'Games Won: $gamesWon\n'
                              'Games Lost: $gamesLost',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
