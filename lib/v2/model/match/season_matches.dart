import 'package:flutter/material.dart';
import 'package:primea/main.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/season/season.dart';
import 'package:primea/v2/model/deck/deck_list.dart';
import 'package:primea/v2/model/season/season_list.dart';

class SeasonMatches extends ChangeNotifier {
  final Map<Season, Iterable<MatchModel>> _matches = {};
  SeasonList _seasons;
  DeckList _deckList;

  SeasonMatches({
    required SeasonList seasons,
    required DeckList deckList,
  })  : _seasons = seasons,
        _deckList = deckList;

  int get length => _matches.length;

  set seasons(SeasonList seasons) {
    _seasons = seasons;
    notifyListeners();
  }

  set deckList(DeckList deckList) {
    _deckList = deckList;
    notifyListeners();
  }

  void reset() {
    _matches.clear();
    _deckList = DeckList.empty();
    notifyListeners();
  }

  Future<Iterable<MatchModel>> fetchMatchesForSeason(Season? season) async {
    if (_matches.containsKey(season)) {
      return _matches[season]!;
    } else if (season != null) {
      final matches = await supabase
          .from(MatchModel.gamesTableName)
          .select()
          .eq('season', season.id)
          .order('game_time', ascending: true)
          .then((event) async {
        Iterable<MatchModel> matches = [];
        try {
          for (final e in event) {
            if (e['deck_id'] != null) {
              e['deck'] = await _deckList.findDeck(e['deck_id']);
            }
            matches = matches.followedBy([MatchModel.fromJson(e)]);
          }
        } on Error catch (e) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: e,
              stack: e.stackTrace,
            ),
          );
        }
        return matches;
      });

      _matches[season] = matches;
      notifyListeners();
      return matches;
    } else {
      return [];
    }
  }

  Iterable<MatchModel>? getMatches(Season? season) {
    if (!_matches.containsKey(season) || season == null) {
      return null;
    } else {
      return _matches[season];
    }
  }

  void addMatch(MatchModel newMatch) {
    final season = _seasons.getSeason(newMatch.season!);

    if (_matches.containsKey(season)) {
      _matches[season] = _matches[season]!.followedBy([newMatch]);
    } else {
      _matches[season] = [newMatch];
    }

    notifyListeners();
  }

  Future<void> setMatches(
      Season season, Future<Iterable<MatchModel>> matches) async {
    _matches[season] = await matches;
    notifyListeners();
  }

  @override
  String toString() {
    return _matches.toString();
  }
}
