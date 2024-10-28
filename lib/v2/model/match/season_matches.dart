import 'package:flutter/material.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/season/season.dart';
import 'package:primea/v2/model/season/season_list.dart';

class SeasonMatches extends ChangeNotifier {
  final Map<Season, Future<Iterable<MatchModel>>> _matches = {};
  final Future<SeasonList> _seasons;

  SeasonMatches({required Future<SeasonList> seasons}) : _seasons = seasons;

  int get length => _matches.length;

  Future<Iterable<MatchModel>>? getMatches(Season? season) {
    return _matches[season];
  }

  Future<void> addMatch(MatchModel newMatch) async {
    final season = (await _seasons).getSeason(newMatch.season!);

    final seasonMatches = _matches[season];
    if (seasonMatches != null) {
      final s = await seasonMatches;
      s.followedBy([newMatch]);
    } else {
      _matches[season] = Future.value([newMatch]);
    }

    notifyListeners();
  }

  void setMatches(Season season, Future<Iterable<MatchModel>> matches) {
    _matches[season] = matches;
    notifyListeners();
  }

  @override
  String toString() {
    return _matches.toString();
  }
}
