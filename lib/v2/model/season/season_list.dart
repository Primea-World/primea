import 'package:flutter/foundation.dart';
import 'package:primea/model/season/season.dart';

class SeasonList extends ChangeNotifier {
  Iterable<Season> _seasons = [];

  Iterable<Season> get seasons => _seasons;

  Season get currentSeason {
    final now = DateTime.now().toUtc();
    return _seasons.firstWhere(
      (element) =>
          now.isAfter(element.startDate) && now.isBefore(element.endDate),
      orElse: () => _seasons.first,
    );
  }

  Season getSeason(int id) {
    return _seasons.firstWhere((element) => element.id == id);
  }

  SeasonList.fromJson(List<Map<String, dynamic>> json) {
    _seasons = json.map((e) => Season.fromJson(e));
  }

  void addSeason(Season season) {
    _seasons.followedBy([season]);
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
