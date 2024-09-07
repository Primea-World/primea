import 'package:flutter/material.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/season/season.dart';

class SeasonMatches extends ChangeNotifier {
  final Map<Season, Stream<Iterable<MatchModel>>> _matches = {};

  int get length => _matches.length;

  Stream<Iterable<MatchModel>>? getMatches(Season? season) {
    return _matches[season];
  }

  void setMatches(Season season, Stream<Iterable<MatchModel>> matches) {
    _matches[season] = matches;
    notifyListeners();
  }
}
