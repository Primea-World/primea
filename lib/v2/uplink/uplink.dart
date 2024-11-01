import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:primea/inherited_session.dart';
import 'package:primea/main.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/twitch/twitch_embed.dart';
import 'package:http/http.dart' as http;
import 'package:primea/util/breakpoint.dart';
import 'package:primea/v2/border/echelon_border.dart';
import 'package:primea/v2/footer.dart';
import 'package:primea/v2/match/labeled_value.dart';
import 'package:primea/v2/model/account.dart';
import 'package:primea/v2/model/season/season_list.dart';
import 'package:primea/v2/uplink/paragon_insights.dart';
import 'package:primea/v2/uplink/player_panel.dart';
import 'package:primea/v2/uplink/stream_response.dart';
import 'package:primea/v2/uplink/twitch_stream_card.dart';
import 'package:primea/v2/logo/logo_painter.dart';
import 'package:vector_graphics/vector_graphics.dart';

class Uplink extends StatefulWidget {
  final ScrollController scrollController;

  const Uplink({
    super.key,
    required this.scrollController,
  });

  @override
  State<StatefulWidget> createState() => _UplinkState();
}

class _UplinkState extends State<Uplink>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  StreamResponse? _selectedStream;
  StreamResponse? _hoveredStream;

  final GlobalKey<AnimatedListState> _streamListState =
      GlobalKey<AnimatedListState>();

  late final AnimationController _accessController;
  late final Animation<double> _openAnimation;
  late final Animation<double> _deniedAnimation;
  late final Animation<double> _grantedAnimation;

  late final AnimationController _winRateController;
  late final Animation<double> _winRateAnimation;
  late final Animation<Color?> _winRateColorAnimation;

  final TweenSequence<Color?> _winRateColorTween = TweenSequence<Color?>(
    [
      TweenSequenceItem<Color?>(
        tween: ColorTween(begin: Colors.red, end: Colors.amber),
        weight: .8,
      ),
      TweenSequenceItem<Color?>(
        tween: ColorTween(begin: Colors.amber, end: Colors.green),
        weight: 1.2,
      ),
    ],
  );

  late final SeasonList _seasons = InheritedAccount.of(context).seasons;
  late final Future<Iterable<ParagonStats>> _paragonStats = _getParagonStats();

  final _parallels = ParallelType.values.where(
    (paragon) => paragon != ParallelType.universal,
  );
  late final Map<ParallelType, AnimationController> _parallelStatsControllers;
  late final Map<ParallelType, Animation<double>> _parallelStatsAnimations;

  bool _firstHovered = false;
  bool _secondHovered = false;

  final String _baseUrl = kDebugMode
      ? 'http://localhost:54321'
      : 'https://fdrysfgctvdtvrxpldxb.supabase.co';

  Iterable<StreamResponse> _streams = [];
  // Iterable<ClipResponse> _clips = [];

  late final _content = http.get(
      Uri.parse(
        "$_baseUrl/functions/v1/twitch_content",
      ),
      headers: {
        "Authorization":
            "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkcnlzZmdjdHZkdHZyeHBsZHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEyNDMyMjgsImV4cCI6MjAzNjgxOTIyOH0.7wcpER7Kch2A9zm5MiTKowd7IQ3Q2jSVkDytGzdTZHU"
      });

  Future<Iterable<ParagonStats>> _getParagonStats() => supabase
      .rpc<List<Map<String, dynamic>>>('get_paragon_match_count')
      .order('total_count')
      .then((values) => values.map(ParagonStats.fromJson));

  final _initialParagonStats = Paragon.values
      .where(
          (paragon) => paragon.title.isNotEmpty && paragon != Paragon.unknown)
      .map((paragon) => ParagonStats(
            paragon: paragon,
            gamesPlayed: 0,
            gamesWon: 0,
            gamesLost: 0,
          ));

  @override
  initState() {
    super.initState();

    _parallelStatsControllers = Map.fromEntries(_parallels.map(
      (parallel) => MapEntry(
          parallel,
          AnimationController(
            vsync: this,
            duration: Durations.medium1,
          )),
    ));
    _parallelStatsAnimations = _parallelStatsControllers.map(
      (parallel, controller) => MapEntry(
        parallel,
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _winRateController = AnimationController(
      vsync: this,
      duration: Durations.medium4,
    );
    _winRateAnimation = CurvedAnimation(
      parent: _winRateController,
      curve: Curves.linear,
    );
    _winRateColorAnimation = _winRateColorTween.animate(CurvedAnimation(
      parent: _winRateController,
      curve: Curves.linear,
    ));

    _accessController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _openAnimation = CurvedAnimation(
      parent: _accessController,
      curve: Interval(0.0, 0.25, curve: Curves.easeOut),
      reverseCurve: Interval(0.0, 0.25, curve: Curves.easeIn),
    );
    _deniedAnimation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween(
            begin: 0.0,
            end: 1.0,
          ),
          weight: 0.5,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.0,
            end: 0.0,
          ),
          weight: 0.5,
        ),
      ],
    ).animate(CurvedAnimation(
      parent: _accessController,
      curve: Interval(0.25, 0.75, curve: Curves.linear),
      reverseCurve: Interval(0.0, 0.0, curve: Curves.bounceIn),
    ));
    _grantedAnimation = CurvedAnimation(
      parent: _accessController,
      curve: Interval(0.75, 1.0, curve: Curves.bounceOut),
      reverseCurve: Interval(0.25, 1.0, curve: Curves.bounceIn),
    );

    _content.then(
      (response) {
        final body = jsonDecode(response.body);
        _streams = (body['streams'] as List<dynamic>)
            .map((element) => StreamResponse.fromJson(element));

        if (_streams.isNotEmpty) {
          _streamListState.currentState?.removeAllItems(
            (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: FadeTransition(
                  opacity: animation,
                  child: SizedBox(
                    width: 350,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            },
            duration: Durations.short4,
          );
          _streamListState.currentState?.insertAllItems(
            0,
            _streams.length,
            duration: Durations.short4,
          );
        }

        // _clips = (body['clips'] as List<dynamic>)
        //     .map((element) => ClipResponse.fromJson(element));
        return true;
      },
    );
  }

  @override
  void dispose() {
    _parallelStatsControllers.forEach((_, controller) {
      controller.dispose();
    });
    _accessController.dispose();
    _winRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final session = InheritedSession.of(context).session;
    if (session == null) {
      _accessController.animateTo(0.5, duration: Duration(milliseconds: 1500));
    } else if (_accessController.status == AnimationStatus.completed) {
      _accessController.forward().then((_) => _accessController.reverse());
    }

    return CustomScrollView(
      slivers: [
        DecoratedSliver(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.onSurface,
                width: .5,
              ),
            ),
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          width: .5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: MediaQuery.of(context).size.width <
                          Breakpoint.desktop.width
                      ? 2
                      : 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 250,
                            minWidth: 175,
                          ),
                          padding: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                            top: 48,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                width: .5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              right: BorderSide(
                                width: .5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "PRIMEA",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(125),
                                    ),
                                textScaler: TextScaler.linear(.75),
                              ),
                              Text(
                                "//",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(125),
                                    ),
                                textScaler: TextScaler.linear(.75),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverFixedExtentList.list(
          itemExtent: 326,
          children: [
            Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                ListenableBuilder(
                  listenable: InheritedAccount.of(context).matches,
                  builder: (context, _) => PlayerPanel(
                    user: session?.user.userMetadata?['nickname'] ??
                        session?.user.email,
                    season: InheritedAccount.of(context).seasons.currentSeason,
                    matches: InheritedAccount.of(context).matches.getMatches(
                          InheritedAccount.of(context).seasons.currentSeason,
                        ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "PROTOCOL ONLINE",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(125),
                                    fontStyle: FontStyle.italic,
                                  ),
                              textScaler: TextScaler.linear(.75),
                            ),
                          ),
                          Flexible(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: ListenableBuilder(
                                    listenable:
                                        InheritedAccount.of(context).matches,
                                    builder: (context, _) => ListenableBuilder(
                                      listenable: _accessController,
                                      builder: (context, _) => ScaleTransition(
                                        scale: _openAnimation,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                Breakpoint.tablet.width - 152,
                                          ),
                                          margin: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            bottom: 16,
                                          ),
                                          decoration: ShapeDecoration(
                                            color:
                                                Colors.white.withOpacity(.35),
                                            shape: EchelonBorder(
                                              radius: const Radius.circular(8),
                                              right: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                width: 2,
                                              ),
                                              left: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 10,
                                                sigmaY: 10,
                                              ),
                                              blendMode: BlendMode.srcOver,
                                              child: Center(
                                                child: FittedBox(
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      FadeTransition(
                                                        opacity:
                                                            _deniedAnimation,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.black38,
                                                            border: Border.all(
                                                              color: Colors.red,
                                                              width: 4,
                                                            ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          child: Text(
                                                            "ACCESS DENIED",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium
                                                                ?.copyWith(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      FadeTransition(
                                                        opacity:
                                                            _grantedAnimation,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.black38,
                                                            border: Border.all(
                                                              color:
                                                                  Colors.green,
                                                              width: 4,
                                                            ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16),
                                                          child: Text(
                                                            "ACCESS GRANTED",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium
                                                                ?.copyWith(
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: MediaQuery.of(context).size.width <
                              Breakpoint.desktop.width
                          ? 2
                          : 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            // TODO: put the logo behind the win rate
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 250,
                                minWidth: 175,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border(
                                  left: BorderSide(
                                    width: .5,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  right: BorderSide(
                                    width: .5,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  bottom: BorderSide(
                                    width: .5,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: FadeTransition(
                                      opacity: Animation.fromValueListenable(
                                        ValueNotifier(.1),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: CustomPaint(
                                          painter: LogoPainter(
                                            primaryColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: session == null
                                            ? Icon(
                                                Icons.close,
                                                size: 150,
                                                color:
                                                    Colors.red.withOpacity(.75),
                                              )
                                            : ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight: 250,
                                                  maxWidth: 250,
                                                ),
                                                child: ListenableBuilder(
                                                  listenable:
                                                      InheritedAccount.of(
                                                              context,
                                                              AccountAspect
                                                                  .matches)
                                                          .matches,
                                                  builder: (context, child) {
                                                    final seasons =
                                                        InheritedAccount.of(
                                                                context,
                                                                AccountAspect
                                                                    .seasons)
                                                            .seasons;
                                                    final matches =
                                                        InheritedAccount.of(
                                                                context,
                                                                AccountAspect
                                                                    .matches)
                                                            .matches
                                                            .getMatches(seasons
                                                                .currentSeason);

                                                    final filteredMatches =
                                                        _firstHovered
                                                            ? matches?.where(
                                                                (match) =>
                                                                    match
                                                                        .playerTurn ==
                                                                    PlayerTurn
                                                                        .going1st)
                                                            : _secondHovered
                                                                ? matches?.where(
                                                                    (match) =>
                                                                        match
                                                                            .playerTurn ==
                                                                        PlayerTurn
                                                                            .going2nd)
                                                                : matches;
                                                    final wins =
                                                        filteredMatches?.fold(
                                                              0,
                                                              (acc, match) =>
                                                                  acc +
                                                                  (match.result ==
                                                                          MatchResultOption
                                                                              .win
                                                                      ? 1
                                                                      : 0),
                                                            ) ??
                                                            0;
                                                    final winRate = wins /
                                                        (filteredMatches
                                                                ?.length ??
                                                            1);

                                                    final first = matches?.fold(
                                                          0,
                                                          (acc, match) =>
                                                              acc +
                                                              (match.playerTurn ==
                                                                      PlayerTurn
                                                                          .going1st
                                                                  ? 1
                                                                  : 0),
                                                        ) ??
                                                        0;
                                                    final second =
                                                        matches?.fold(
                                                              0,
                                                              (acc, match) =>
                                                                  acc +
                                                                  (match.playerTurn ==
                                                                          PlayerTurn
                                                                              .going2nd
                                                                      ? 1
                                                                      : 0),
                                                            ) ??
                                                            0;

                                                    _winRateController
                                                        .animateTo(
                                                      winRate,
                                                      curve: Curves.easeInOut,
                                                      duration:
                                                          Durations.medium2,
                                                    );
                                                    return ListenableBuilder(
                                                      listenable:
                                                          _winRateAnimation,
                                                      builder: (context, _) {
                                                        return Stack(
                                                          fit: StackFit.expand,
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                24,
                                                              ),
                                                              child:
                                                                  CircularProgressIndicator(
                                                                value:
                                                                    _winRateAnimation
                                                                        .value,
                                                                valueColor:
                                                                    _winRateColorAnimation,
                                                                strokeWidth: 2,
                                                                backgroundColor: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .surfaceContainerHighest,
                                                              ),
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "${(_winRateAnimation.value * 100).toStringAsFixed(0)}%",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .displaySmall,
                                                                ),
                                                                Text(
                                                                  _firstHovered
                                                                      ? "ON THE PLAY"
                                                                      : _secondHovered
                                                                          ? "ON THE DRAW"
                                                                          : "WIN RATE",
                                                                ),
                                                              ],
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              left: 0,
                                                              child: InkWell(
                                                                child: RichText(
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                    _firstHovered
                                                                        ? 1.5
                                                                        : 1,
                                                                  ),
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "1ST\n",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                      ),
                                                                      TextSpan(
                                                                        text: first
                                                                            .toString(),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                onTap: () {},
                                                                onHover:
                                                                    (value) async {
                                                                  setState(() {
                                                                    _firstHovered =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: InkWell(
                                                                child: RichText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  textScaler:
                                                                      TextScaler
                                                                          .linear(
                                                                    _secondHovered
                                                                        ? 1.5
                                                                        : 1,
                                                                  ),
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "2ND\n",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                      ),
                                                                      TextSpan(
                                                                        text: second
                                                                            .toString(),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyLarge,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                onTap: () {},
                                                                onHover:
                                                                    (value) {
                                                                  setState(() {
                                                                    _secondHovered =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // DecoratedSliver(
        //   decoration: BoxDecoration(
        //     border: Border(
        //       bottom: BorderSide(
        //         color: Theme.of(context).colorScheme.onSurface,
        //         width: .5,
        //       ),
        //     ),
        //   ),
        //   sliver: SliverToBoxAdapter(
        //     child: Row(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Expanded(
        // flex: MediaQuery.of(context).size.width <
        //         Breakpoint.desktop.width
        //     ? 2
        //     : 3,
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.end,
        //             // crossAxisAlignment: CrossAxisAlignment.stretch,
        //             children: [
        //               Flexible(
        //                 fit: FlexFit.loose,
        //                 child: Container(
        //                   padding: EdgeInsets.only(right: 8, top: 16),
        //                   constraints: BoxConstraints(
        //                     maxWidth: 250,
        //                     minWidth: 175,
        //                   ),
        //                   child: Text(
        //                     "UPCOMING EVENTS",
        //                     textAlign: TextAlign.end,
        //                     style: Theme.of(context).textTheme.headlineMedium,
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Expanded(
        //           flex: 3,
        //           child: Container(
        //             decoration: BoxDecoration(
        //               border: Border(
        //                 left: BorderSide(
        //                   color: Theme.of(context).colorScheme.onSurface,
        //                   width: .5,
        //                 ),
        //               ),
        //             ),
        //             padding:
        //                 EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 16),
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 FittedBox(
        //                   child: Text(
        //                     "NO UPCOMING EVENTS FOUND",
        //                     style: Theme.of(context).textTheme.displayMedium,
        //                   ),
        //                 ),
        //                 ConstrainedBox(
        //                   constraints: BoxConstraints(maxWidth: 450),
        //                   child: Text(
        //                     "Elevate your Parallel game with win rates and meta insights. Track stats, refine your strategy, and lead your parallel to victory.",
        //                     style: Theme.of(context)
        //                         .textTheme
        //                         .labelLarge
        //                         ?.copyWith(
        //                           color: Theme.of(context)
        //                               .colorScheme
        //                               .onSurface
        //                               .withAlpha(200),
        //                         ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        SliverList.builder(
          itemCount: _parallels.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
              initialData: _initialParagonStats,
              future: _paragonStats,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                final parallel = _parallels.elementAt(index);
                int matches = 0, wins = 0, losses = 0;
                double winRate = 0.0;

                final paragonStats = snapshot.data?.where(
                  (stats) => stats.paragon.parallel == parallel,
                );

                Iterable<ParagonStats> fullStats;

                if (paragonStats != null) {
                  for (var stats in paragonStats) {
                    matches += stats.gamesPlayed;
                    wins += stats.gamesWon;
                    losses += stats.gamesLost;
                  }
                  winRate = wins / (matches == 0 ? 1 : matches);
                  fullStats = Paragon.values
                      .where(
                    (paragon) =>
                        paragon.parallel == parallel &&
                        paragon.title.isNotEmpty,
                  )
                      .map((paragon) {
                    if (paragonStats.any((stats) => stats.paragon == paragon)) {
                      return paragonStats.firstWhere(
                        (stats) => stats.paragon == paragon,
                      );
                    } else {
                      return ParagonStats(
                        paragon: paragon,
                        gamesPlayed: 0,
                        gamesWon: 0,
                        gamesLost: 0,
                      );
                    }
                  });
                } else {
                  fullStats = Paragon.values
                      .where(
                        (paragon) =>
                            paragon.parallel == parallel &&
                            paragon.title.isNotEmpty,
                      )
                      .map(
                        (paragon) => ParagonStats(
                          paragon: paragon,
                          gamesPlayed: 0,
                          gamesWon: 0,
                          gamesLost: 0,
                        ),
                      );
                }

                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: InkWell(
                      onTap: () {},
                      onHover: (value) {
                        if (value) {
                          _parallelStatsControllers[parallel]?.forward();
                        } else {
                          _parallelStatsControllers[parallel]?.reverse();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: .5,
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: Breakpoint.desktop.width,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.width >
                                        Breakpoint.phone.width
                                    ? 150
                                    : 450,
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection:
                                    MediaQuery.of(context).size.width >
                                            Breakpoint.phone.width
                                        ? Axis.horizontal
                                        : Axis.vertical,
                                itemExtentBuilder: (index, dimensions) {
                                  return MediaQuery.of(context).size.width >
                                          Breakpoint.phone.width
                                      ? min(
                                          MediaQuery.of(context).size.width / 3,
                                          Breakpoint.desktop.width / 3)
                                      : 156;
                                },
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 150),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: SvgPicture(
                                        AssetBytesLoader(
                                          "assets/parallel_logos/vec/${parallel.title}.svg.vec",
                                        ),
                                        colorFilter: ColorFilter.mode(
                                          parallel.color,
                                          BlendMode.srcATop,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          parallel.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                        ),
                                        ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: 350),
                                          child: Table(
                                            children: [
                                              TableRow(
                                                children: [
                                                  TableCell(
                                                    child: LabeledValue(
                                                      label: "GAMES",
                                                      value: matches.toString(),
                                                      borderColor: const Color(
                                                          0xaadff141),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: LabeledValue(
                                                      label: "WON",
                                                      value: wins.toString(),
                                                      borderColor: const Color(
                                                          0xaa43ff64),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    child: LabeledValue(
                                                      label: "LOST",
                                                      value: losses.toString(),
                                                      borderColor: const Color(
                                                          0xaaff7433),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(24),
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: CircularProgressIndicator(
                                              value: winRate,
                                              color: _winRateColorTween
                                                  .transform(winRate),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              strokeWidth: 4,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${(winRate * 100).toStringAsFixed(0)}%",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            Text(
                                              "WIN RATE",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListenableBuilder(
                              listenable: _parallelStatsAnimations[parallel]!,
                              builder: (context, _) => FadeTransition(
                                opacity: _parallelStatsAnimations[parallel]!,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.width >
                                                Breakpoint.phone.width
                                            ? 150
                                            : 450,
                                  ),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: fullStats.length,
                                      scrollDirection:
                                          MediaQuery.of(context).size.width >
                                                  Breakpoint.phone.width
                                              ? Axis.horizontal
                                              : Axis.vertical,
                                      itemExtentBuilder: (index, dimensions) {
                                        return MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                Breakpoint.phone.width
                                            ? min(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3,
                                                Breakpoint.desktop.width / 3)
                                            : 150;
                                      },
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final stat = fullStats.elementAt(index);
                                        final paragon = stat.paragon;
                                        return Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 100 / 120,
                                              child: Image(
                                                alignment:
                                                    Alignment.topCenter.add(
                                                  Alignment(0, 0.25),
                                                ),
                                                fit: BoxFit.cover,
                                                image: AssetImage(paragon.art ??
                                                    paragon.image!),
                                              ),
                                            ),
                                            Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                                  .withAlpha(150),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    paragon.title,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium,
                                                  ),
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                        maxWidth: 350),
                                                    child: Table(
                                                      children: [
                                                        TableRow(
                                                          children: [
                                                            TableCell(
                                                              child:
                                                                  LabeledValue(
                                                                label: "GAMES",
                                                                value: stat
                                                                    .gamesPlayed
                                                                    .toString(),
                                                                borderColor:
                                                                    const Color(
                                                                        0xaadff141),
                                                              ),
                                                            ),
                                                            TableCell(
                                                              child:
                                                                  LabeledValue(
                                                                label: "WON",
                                                                value: stat
                                                                    .gamesWon
                                                                    .toString(),
                                                                borderColor:
                                                                    const Color(
                                                                        0xaa43ff64),
                                                              ),
                                                            ),
                                                            TableCell(
                                                              child:
                                                                  LabeledValue(
                                                                label: "LOST",
                                                                value: stat
                                                                    .gamesLost
                                                                    .toString(),
                                                                borderColor:
                                                                    const Color(
                                                                        0xaaff7433),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 8),
          sliver: SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 282),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          "TWITCH STREAMS",
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: EchelonBorder(
                              radius: const Radius.circular(8),
                              left: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 0.5,
                              ),
                              right: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: SizedBox(
                            height: 266,
                            child: AnimatedSwitcher(
                              duration: Durations.long4,
                              child: FutureBuilder(
                                future: _content,
                                builder: (context, snapshot) {
                                  return AnimatedList(
                                    key: _streamListState,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    initialItemCount: 1,
                                    itemBuilder: (context, index, animation) {
                                      if (snapshot.connectionState !=
                                          ConnectionState.done) {
                                        return SizedBox(
                                          width: 350,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return SizedBox(
                                          width: 350,
                                          child: Center(
                                            child: Text(
                                                "Error: ${snapshot.error}"),
                                          ),
                                        );
                                      } else if (_streams.isEmpty) {
                                        return SizedBox(
                                          width: 350,
                                          child: Center(
                                            child: Text("No streams available"),
                                          ),
                                        );
                                      }
                                      final element = _streams.elementAt(index);

                                      return SizeTransition(
                                        sizeFactor: animation,
                                        axis: Axis.horizontal,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: InkWell(
                                            onHover: (value) {
                                              if (value) {
                                                if (_hoveredStream?.id !=
                                                    element.id) {
                                                  setState(() {
                                                    _hoveredStream = element;
                                                  });
                                                }
                                              } else {
                                                if (_hoveredStream?.id ==
                                                    element.id) {
                                                  setState(() {
                                                    _hoveredStream = null;
                                                  });
                                                }
                                              }
                                            },
                                            onTap: () {
                                              setState(() {
                                                if (_selectedStream?.userId ==
                                                    element.userId) {
                                                  _selectedStream = null;
                                                } else {
                                                  _selectedStream = element;
                                                }
                                              });
                                            },
                                            child: TwitchStreamCard(
                                              isHovered: _hoveredStream?.id ==
                                                  element.id,
                                              isSelected: _selectedStream?.id ==
                                                  element.id,
                                              stream: element,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: TwitchEmbed(channel: _selectedStream?.userName),
          ),
        ),
        SliverToBoxAdapter(
          child: Footer(),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
