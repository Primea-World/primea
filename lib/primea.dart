import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/main.dart';
import 'package:primea/modal/sign_in.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/season/season.dart';
import 'package:primea/route_information_parser.dart';
import 'package:primea/router_delegate.dart';
import 'package:primea/util/analytics.dart';
import 'package:primea/util/breakpoint.dart';
import 'package:primea/v2/border/menu_border.dart';
import 'package:primea/v2/echelon_logo.dart/echelon_logo_painter.dart';
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

  final Future<SeasonList> _seasons = supabase
      .from(Season.seasonsTableName)
      .select()
      .order('season_start', ascending: false)
      .then((seasons) => SeasonList.fromJson(seasons));

  Future<DeckList>? _decks;
  late SeasonMatches _matches = SeasonMatches(seasons: _seasons);

  bool _signInHovered = false;
  bool _signInSelected = false;

  final _appBarActions = [
    PrimeaUplinkPage(),
    PrimeaMatchesPage(),
    PrimeaConsolePage(),
    PrimeaProfilePage(),
  ];

  late final Map<PrimeaPage, bool> _appBarActionStates = {
    for (final action in _appBarActions) action: false
  };

  RealtimeChannel subscribeMatches() {
    return supabase
        .channel(
            "public.${MatchModel.gamesTableName}.${Random(DateTime.now().microsecondsSinceEpoch).nextInt(1 << 32)}")
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: "public",
          table: MatchModel.gamesTableName,
          // TODO: filter this so other users deletions don't trigger this subscription
          callback: (payload) async {
            print("payload: $payload");
            switch (payload.eventType) {
              case PostgresChangeEvent.all:
                FlutterError.reportError(
                  FlutterErrorDetails(
                    exception: Exception(
                        "cannot handle PostgresChangeEvent.all from public.${MatchModel.gamesTableName} ($payload)"),
                  ),
                );
                break;
              case PostgresChangeEvent.insert:
                final newMatch = MatchModel.fromJson(payload.newRecord);
                _matches.addMatch(newMatch);
              case PostgresChangeEvent.update:
              // TODO: Handle this case.
              case PostgresChangeEvent.delete:
              // TODO: Handle this case.
            }
          },
        )
        .subscribe(
            // (status, payload) async {
            //   switch (status) {
            //     case RealtimeSubscribeStatus.subscribed:
            //       if (kDebugMode) {
            //         print("subscribed to games");
            //       }
            //       break;
            //     case RealtimeSubscribeStatus.channelError:
            //       FlutterError.reportError(
            //         FlutterErrorDetails(
            //           exception: payload ??
            //               Exception(
            //                   "unknown error with public.${MatchModel.gamesTableName} subscription"),
            //         ),
            //       );
            //       await matchesSubscription.unsubscribe();
            //       matchesSubscription = subscribeMatches();
            //       break;
            //     case RealtimeSubscribeStatus.closed:
            //       // if (kDebugMode) {
            //       //   print("channel closed");
            //       // }
            //       await matchesSubscription.unsubscribe();
            //       Future.delayed(Durations.short1, () {
            //         matchesSubscription = subscribeMatches();
            //       });
            //       break;
            //     case RealtimeSubscribeStatus.timedOut:
            //       if (kDebugMode) {
            //         print("channel timed out");
            //       }
            //       await matchesSubscription.unsubscribe();
            //       matchesSubscription = subscribeMatches();
            //   }
            // },
            );
  }

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
          _matches = SeasonMatches(seasons: _seasons);
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

            final currentSeason = (await _seasons).seasons.first;

            final matches = supabase
                .from(MatchModel.gamesTableName)
                .select()
                .eq('season', currentSeason.id)
                .order('game_time', ascending: false)
                .then((event) async {
              Iterable<MatchModel> matches = [];
              try {
                for (final e in event) {
                  if (e['deck_id'] != null) {
                    e['deck'] = await (await _decks)?.findDeck(e['deck_id']);
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

            _matches.setMatches(currentSeason, matches);
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
    return
        // InheritedSession(
        //   session: session,
        //   child: InheritedAccount(
        //     seasons: _seasons,
        //     decks: _decks,
        //     matches: _matches,
        //     child:
        Scaffold(
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
                                    widget.routerDelegate.selectedPage == e.$2
                                ? null
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            fontSize: 8,
                          ),
                      text: "DATA_PANEL[${e.$1 + 1}]",
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        e.$2.title,
                        style: _appBarActionStates[e.$2] ?? false
                            ? Theme.of(context).textTheme.headlineMedium?.apply(
                                  color: Theme.of(context).colorScheme.primary,
                                )
                            : Theme.of(context).textTheme.headlineSmall?.apply(
                                  heightDelta: .15,
                                ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  widget.routerDelegate.setSelectedPage(e.$2);
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                primaryColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
          ),
          onPressed: () {},
        ),
        title: Text(widget.title),
        actions: [
          if (MediaQuery.of(context).size.width >= Breakpoint.tablet.width)
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
                                    widget.routerDelegate.selectedPage == e.$2
                                ? null
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            fontSize: 8,
                          ),
                      text: "DATA_PANEL[${e.$1 + 1}]",
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
                              color: Theme.of(context).colorScheme.primary,
                            )
                        : Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                onTap: () {
                  widget.routerDelegate.setSelectedPage(e.$2);
                },
                onHover: (value) {
                  setState(() {
                    _appBarActionStates[e.$2] = value;
                  });
                },
              ),
            ),
          if (MediaQuery.of(context).size.width < Breakpoint.tablet.width &&
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
          if (session == null)
            InkWell(
              child: Container(
                decoration: ShapeDecoration(
                  shape: MenuBorder(
                    textStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: _signInSelected
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
                _signInSelected = true;
                final result = await showDialog(
                  context: widget._navigatorKey.currentContext!,
                  builder: (context) {
                    return SignInModal();
                  },
                );
                _signInSelected = false;
              },
              onHover: (value) {
                setState(() {
                  _signInHovered = value;
                });
              },
            ),
        ],
      ),
      body: ListView(
        children: [
          widget.body!,
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: .5,
                ),
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 54,
                          child: AspectRatio(
                            aspectRatio: 2,
                            child: CustomPaint(
                              painter: EchelonLogoPainter(
                                primaryColor:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ECHELON\nFOUNDATION",
                                style: GoogleFonts.chakraPetch(
                                  textStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "OFFICIAL PARTNER",
                      style: GoogleFonts.chakraPetch(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                        fontWeight: FontWeight.w100,
                      ).copyWith(
                        letterSpacing: 2.1,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Primea World © 2024",
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      //   ),
      // ),
    );
  }
}
