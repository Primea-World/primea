import 'package:flutter/material.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/main.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/season/season.dart';
import 'package:primea/route_information_parser.dart';
import 'package:primea/router_delegate.dart';
import 'package:primea/util/analytics.dart';
import 'package:primea/v2/model/account.dart';
import 'package:primea/v2/model/deck/deck_list.dart';
import 'package:primea/v2/model/match/season_matches.dart';
import 'package:primea/v2/model/season/season_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Primea extends StatefulWidget {
  final String title;
  final Widget? body;
  final PrimeaRouterDelegate routerDelegate;

  const Primea({
    super.key,
    required this.title,
    required this.body,
    required this.routerDelegate,
  });

  @override
  State<StatefulWidget> createState() => _PrimeaState();
}

class _PrimeaState extends State<Primea> {
  Session? session = Supabase.instance.client.auth.currentSession;

  final Future<SeasonList> _seasons = supabase
      .from(Season.seasonsTableName)
      .select()
      .order('season_start', ascending: true)
      .then((seasons) => SeasonList.fromJson(seasons));

  Future<DeckList>? _decks;
  SeasonMatches _matches = SeasonMatches();

  void handleAuthStateChange(AuthState data) async {
    Analytics.instance.trackEvent(
      "authStateChanged",
      {"event": data.event.name},
    );

    session = data.session;
    switch (data.event) {
      case AuthChangeEvent.signedOut:
        setState(() {
          _decks = null;
          _matches = SeasonMatches();
        });
        break;
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
        if (session != null && !session!.isExpired) {
          try {
            _decks = supabase
                .from(Deck.decksTableName)
                .select()
                .eq('hidden', false)
                .then((decks) => DeckList.fromJson(decks));

            final currentSeason = (await _seasons).currentSeason;

            final Stream<Iterable<MatchModel>> seasonMatches = supabase
                .from(MatchModel.gamesTableName)
                .stream(primaryKey: ['id', 'user_id', 'created_at'])
                .eq('season', 11)
                .order('game_time', ascending: false)
                .asyncMap((event) async {
                  Iterable<MatchModel> matches = [];
                  try {
                    for (final e in event) {
                      if (e['deck_id'] != null) {
                        e['deck'] =
                            await (await _decks)?.findDeck(e['deck_id']);
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

            _matches.setMatches(currentSeason, seasonMatches);
          } on Error catch (e) {
            Analytics.instance.trackEvent("primeaInitError", {
              "error": e.toString(),
              "stackTrace": e.stackTrace.toString(),
            });
          }
        }
        break;
      default:
    }
  }

  @override
  void initState() {
    supabase.auth.onAuthStateChange.listen(handleAuthStateChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: InheritedAccount(
        seasons: _seasons,
        decks: _decks,
        matches: _matches,
        child: Scaffold(
          body: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              NavigationRail(
                selectedIndex: PrimeaPage.toIndex(
                    widget.routerDelegate.currentConfiguration.page),
                elevation: 1,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                labelType: NavigationRailLabelType.selected,
                groupAlignment: 0,
                leading: session != null && !session!.isExpired
                    ? FloatingActionButton(
                        child: const Icon(Icons.login_sharp),
                        onPressed: () {},
                      )
                    : FloatingActionButton(
                        child: const Icon(Icons.logout),
                        onPressed: () {},
                      ),
                onDestinationSelected: (index) {
                  widget.routerDelegate
                      .setSelectedPage(PrimeaPage.fromIndex(index));
                },
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.data_array),
                    selectedIcon: Icon(
                      Icons.data_array,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      "Home",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.gamepad_outlined),
                    selectedIcon: Icon(
                      Icons.gamepad_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      "Matches",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  NavigationRailDestination(
                    disabled: false,
                    icon: const Icon(Icons.dashboard),
                    selectedIcon: Icon(
                      Icons.dashboard,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      "Dashboard",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: widget.body ?? Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
