import 'dart:async';

import 'package:flutter/material.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/main.dart';
import 'package:primea/modal/sign_in.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/deck_model.dart';
import 'package:primea/model/season/season.dart';
import 'package:primea/route_information_parser.dart';
import 'package:primea/router_delegate.dart';
import 'package:primea/util/analytics.dart';
import 'package:primea/util/breakpoint.dart';
import 'package:primea/v2/border/menu_border.dart';
import 'package:primea/v2/logo/logo_painter.dart';
import 'package:primea/v2/model/account.dart';
import 'package:primea/v2/model/deck/deck_list.dart';
import 'package:primea/v2/model/match/season_matches.dart';
import 'package:primea/v2/model/season/season_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Primea extends StatefulWidget {
  final String title;
  final Widget? body;
  final PrimeaRouterDelegate routerDelegate;
  final GlobalKey<NavigatorState> _navigatorKey;
  final ScrollController scrollController;

  const Primea({
    super.key,
    required GlobalKey<NavigatorState> navigatorKey,
    required this.title,
    required this.body,
    required this.routerDelegate,
    required this.scrollController,
  }) : _navigatorKey = navigatorKey;

  @override
  State<StatefulWidget> createState() => _PrimeaState();
}

class _PrimeaState extends State<Primea> with SingleTickerProviderStateMixin {
  Session? session = Supabase.instance.client.auth.currentSession;

  late StreamSubscription<AuthState> authSubscription;
  late RealtimeChannel matchesSubscription;

  final SeasonList _seasonList = SeasonList.empty();
  Future<Iterable<Season>> _fetchSeasons() => supabase
      .from(Season.seasonsTableName)
      .select()
      .order('season_start', ascending: false)
      .then((seasons) => seasons.map((season) => Season.fromJson(season)));

  final DeckList _deckList = DeckList.empty();
  Future<Iterable<Deck>> _fetchDecks() =>
      supabase.from(Deck.decksTableName).select().eq('hidden', false).then(
            (decks) => DeckModel.toDecks(
              decks.map(
                (deck) => DeckModel.fromJson(deck),
              ),
            ),
          );

  late final SeasonMatches _matches = SeasonMatches(
    seasons: _seasonList,
    deckList: _deckList,
  );

  bool _signInHovered = false, _signInSelected = false;
  bool _logoutHovered = false;

  late final _appBarActions = [
    PrimeaUplinkPage(),
    PrimeaMatchesPage(),
    // TODO: Implement these pages
    // PrimeaConsolePage(),
    // PrimeaProfilePage(),
  ];

  late final Map<PrimeaPage, bool> _appBarActionStates = {
    for (final action in _appBarActions) action: false
  };

  // RealtimeChannel subscribeMatches() {
  //   return supabase
  //       .channel(
  //           "public.${MatchModel.gamesTableName}.${Random(DateTime.now().microsecondsSinceEpoch).nextInt(1 << 32)}")
  //       .onPostgresChanges(
  //         event: PostgresChangeEvent.all,
  //         schema: "public",
  //         table: MatchModel.gamesTableName,
  //         // TODO: filter this so other users deletions don't trigger this subscription
  //         callback: (payload) async {
  //           print("payload: $payload");
  //           switch (payload.eventType) {
  //             case PostgresChangeEvent.all:
  //               FlutterError.reportError(
  //                 FlutterErrorDetails(
  //                   exception: Exception(
  //                       "cannot handle PostgresChangeEvent.all from public.${MatchModel.gamesTableName} ($payload)"),
  //                 ),
  //               );
  //               break;
  //             case PostgresChangeEvent.insert:
  //               final newMatch = MatchModel.fromJson(payload.newRecord);
  //               _matches?.addMatch(newMatch);
  //             case PostgresChangeEvent.update:
  //             // TODO: Handle this case.
  //             case PostgresChangeEvent.delete:
  //             // TODO: Handle this case.
  //           }
  //         },
  //       )
  //       .subscribe(
  //           // (status, payload) async {
  //           //   switch (status) {
  //           //     case RealtimeSubscribeStatus.subscribed:
  //           //       if (kDebugMode) {
  //           //         print("subscribed to games");
  //           //       }
  //           //       break;
  //           //     case RealtimeSubscribeStatus.channelError:
  //           //       FlutterError.reportError(
  //           //         FlutterErrorDetails(
  //           //           exception: payload ??
  //           //               Exception(
  //           //                   "unknown error with public.${MatchModel.gamesTableName} subscription"),
  //           //         ),
  //           //       );
  //           //       await matchesSubscription.unsubscribe();
  //           //       matchesSubscription = subscribeMatches();
  //           //       break;
  //           //     case RealtimeSubscribeStatus.closed:
  //           //       // if (kDebugMode) {
  //           //       //   print("channel closed");
  //           //       // }
  //           //       await matchesSubscription.unsubscribe();
  //           //       Future.delayed(Durations.short1, () {
  //           //         matchesSubscription = subscribeMatches();
  //           //       });
  //           //       break;
  //           //     case RealtimeSubscribeStatus.timedOut:
  //           //       if (kDebugMode) {
  //           //         print("channel timed out");
  //           //       }
  //           //       await matchesSubscription.unsubscribe();
  //           //       matchesSubscription = subscribeMatches();
  //           //   }
  //           // },
  //           );
  // }

  void handleAuthStateChange(AuthState data) async {
    Analytics.instance.trackEvent(
      "authStateChanged",
      {"event": data.event.name},
    );

    setState(() {
      session = data.session;
    });
    switch (data.event) {
      case AuthChangeEvent.signedOut:
        setState(() {
          _matches.reset();
          _deckList;
        });
        break;
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.signedIn:
        if (session != null && !session!.isExpired) {
          try {
            final decks = await _fetchDecks();

            setState(() {
              _deckList.addDecks(decks);
            });

            await _matches.fetchMatchesForSeason(_seasonList.currentSeason);
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
    authSubscription =
        supabase.auth.onAuthStateChange.listen(handleAuthStateChange);

    _fetchSeasons().then((seasons) {
      _seasonList.addSeasons(seasons);
    });

    // matchesSubscription = subscribeMatches();
    super.initState();
  }

  @override
  void dispose() {
    matchesSubscription.unsubscribe();
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedSession(
      session: session,
      child: InheritedAccount(
        seasons: _seasonList,
        decks: _deckList,
        matches: _matches,
        child: ListenableBuilder(
          listenable: widget.routerDelegate,
          builder: (context, _) => Scaffold(
            endDrawer: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              padding: EdgeInsets.all(16),
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ..._appBarActions.indexed.map(
                    (e) => InkWell(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: ShapeDecoration(
                          shape: MenuBorder(
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: _appBarActionStates[e.$2]! ||
                                          widget.routerDelegate.selectedPage ==
                                              e.$2
                                      ? null
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  fontSize: 8,
                                ),
                            text:
                                "DATA_PANEL[${(e.$1 + 1).toString().padLeft(2, '0')}]",
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              e.$2.title,
                              style: _appBarActionStates[e.$2] ?? false
                                  ? Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                  : Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.apply(
                                        heightDelta: .15,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (widget.routerDelegate.selectedPage == e.$2) return;
                        Navigator.of(widget._navigatorKey.currentContext!)
                            .pushNamed(e.$2.path);
                        Scaffold.of(widget._navigatorKey.currentContext!)
                            .closeEndDrawer();
                      },
                      onHover: (value) {
                        setState(() {
                          _appBarActionStates[e.$2] = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              leading: IconButton(
                icon: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: LogoPainter(
                      // backgroundColor: Theme.of(context).colorScheme.primary,
                      primaryColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPressed: () {},
              ),
              title: Text(widget.title),
              actions: [
                if (MediaQuery.of(context).size.width >=
                        Breakpoint.tablet.width &&
                    session != null)
                  ..._appBarActions.indexed.map(
                    (e) => InkWell(
                      child: Container(
                        decoration: ShapeDecoration(
                          shape: MenuBorder(
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: _appBarActionStates[e.$2]! ||
                                          widget.routerDelegate.selectedPage ==
                                              e.$2
                                      ? null
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  fontSize: 8,
                                ),
                            text:
                                "DATA_PANEL[${(e.$1 + 1).toString().padLeft(2, '0')}]",
                          ),
                        ),
                        padding: EdgeInsets.only(
                          left: 32,
                          top: 8,
                          bottom: 8,
                        ),
                        margin: EdgeInsets.only(right: 12),
                        child: Text(
                          e.$2.title,
                          style: _appBarActionStates[e.$2] ?? false
                              ? Theme.of(context).textTheme.titleMedium?.apply(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                              : Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      onTap: () {
                        if (widget.routerDelegate.selectedPage == e.$2) return;
                        Navigator.of(widget._navigatorKey.currentContext!)
                            .pushNamed(e.$2.path);
                        // widget.routerDelegate.setSelectedPage(e.$2);
                      },
                      onHover: (value) {
                        setState(() {
                          _appBarActionStates[e.$2] = value;
                        });
                      },
                    ),
                  ),
                if (session == null)
                  InkWell(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: MenuBorder(
                          textStyle:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: _signInHovered || _signInSelected
                                        ? null
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    fontSize: 8,
                                  ),
                          text: "AUTH_PANEL[01]",
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 32,
                        top: 8,
                        bottom: 8,
                      ),
                      margin: EdgeInsets.only(right: 12),
                      child: Text(
                        "SIGN IN",
                        style: _signInHovered
                            ? Theme.of(context).textTheme.titleMedium?.apply(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                            : Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    onTap: () async {
                      if (_signInSelected) return;
                      _signInSelected = true;
                      await showGeneralDialog(
                        context: widget._navigatorKey.currentContext!,
                        transitionDuration: Durations.long4,
                        barrierDismissible: true,
                        barrierLabel: "SIGN IN",
                        pageBuilder: (context, animation, secondAnimation) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            child: SignInModal(),
                          );
                        },
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                          final slideAnimation = Tween<Offset>(
                            begin: Offset(0, 1),
                            end: Offset(0, 0),
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Interval(
                                0.0,
                                0.5,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          );

                          final sizeAnimation = Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Interval(
                                0.25,
                                1,
                                curve: Curves.linear,
                              ),
                            ),
                          );

                          return SlideTransition(
                            position: slideAnimation,
                            child: ScaleTransition(
                              scale: sizeAnimation,
                              child: child,
                            ),
                          );
                        },
                      );
                      _signInHovered = false;
                      _logoutHovered = false;
                      _signInSelected = false;
                    },
                    onHover: (value) {
                      setState(() {
                        _signInHovered = value;
                      });
                    },
                  ),
                if (session != null)
                  InkWell(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: MenuBorder(
                          textStyle:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: _logoutHovered
                                        ? null
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    fontSize: 8,
                                  ),
                          text: "AUTH_PANEL[01]",
                        ),
                      ),
                      padding: EdgeInsets.only(
                        left: 32,
                        top: 8,
                        bottom: 8,
                      ),
                      margin: EdgeInsets.only(right: 12),
                      child: Text(
                        "LOGOUT",
                        style: _logoutHovered
                            ? Theme.of(context).textTheme.titleMedium?.apply(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                            : Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    onTap: () async {
                      supabase.auth.signOut();
                    },
                    onHover: (value) {
                      setState(() {
                        _logoutHovered = value;
                      });
                    },
                  ),
                if (MediaQuery.of(context).size.width <
                        Breakpoint.tablet.width &&
                    session != null)
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: .5,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Scaffold.of(widget._navigatorKey.currentContext!)
                            .openEndDrawer();
                      },
                    ),
                  ),
              ],
            ),
            body: widget.body!,
          ),
        ),
      ),
    );
  }
}
