import 'package:flutter/material.dart';
import 'package:primea/v2/model/deck/deck_list.dart';
import 'package:primea/v2/model/match/season_matches.dart';
import 'package:primea/v2/model/season/season_list.dart';

enum AccountAspect {
  matches,
  decks,
  // results,
  seasons,
  summary,
}

class InheritedAccount extends InheritedModel<AccountAspect> {
  const InheritedAccount({
    super.key,
    required super.child,
    required this.matches,
    // required this.results,
    required this.seasons,
    required this.decks,
  });

  final SeasonList seasons;
  final DeckList decks;
  final SeasonMatches matches;
  // final HashMap<Season, MatchResults>? results;

  @override
  bool updateShouldNotify(InheritedAccount oldWidget) {
    return oldWidget.matches != matches ||
        oldWidget.matches.length != matches.length ||
        // oldWidget.results != results ||
        oldWidget.decks != decks ||
        oldWidget.seasons != seasons;
  }

  @override
  bool updateShouldNotifyDependent(
      InheritedAccount oldWidget, Set<AccountAspect> dependencies) {
    return dependencies.contains(AccountAspect.matches) &&
            (oldWidget.matches != matches ||
                oldWidget.matches.length != matches.length) ||
        // dependencies.contains(AccountAspect.results) &&
        //     oldWidget.results != results ||
        dependencies.contains(AccountAspect.seasons) &&
            oldWidget.seasons != seasons;
  }

  static InheritedAccount? maybeOf(BuildContext context,
      [AccountAspect? aspect]) {
    return InheritedModel.inheritFrom<InheritedAccount>(context,
        aspect: aspect);
  }

  static InheritedAccount of(BuildContext context, [AccountAspect? aspect]) {
    final InheritedAccount? result = maybeOf(context, aspect);
    assert(result != null, 'Unable to find an instance of Account');
    return result!;
  }
}
