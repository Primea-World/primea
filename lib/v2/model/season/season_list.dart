import 'package:flutter/foundation.dart';
import 'package:primea/model/season/season.dart';

class SeasonList extends ChangeNotifier {
  SeasonList.empty();

  Iterable<Season> _seasons = [];

  Iterable<Season> get seasons => _seasons;

  Season? get currentSeason {
    final now = DateTime.now().toUtc();
    try {
      return _seasons.firstWhere(
        (element) =>
            now.isAfter(element.startDate) && now.isBefore(element.endDate),
        orElse: () => _seasons.first,
      );
    } on StateError {
      return null;
    }
  }

  Season getSeason(int id) {
    return _seasons.firstWhere((element) => element.id == id);
  }

  SeasonList.fromJson(List<Map<String, dynamic>> json) {
    _seasons = json.map((e) => Season.fromJson(e));
  }

  void addSeasons(Iterable<Season> seasons) {
    _seasons = _seasons.followedBy(seasons);
    notifyListeners();
  }

  void removeSeason(Season season) {
    _seasons = _seasons.where((element) => element != season);
    notifyListeners();
  }

  @override
  String toString() {
    return _seasons.toString();
  }
}
