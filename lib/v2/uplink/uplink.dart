import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:primea/twitch/twitch_embed.dart';
import 'package:http/http.dart' as http;
import 'package:primea/v2/border/echelon_border.dart';
import 'package:primea/v2/uplink/player_panel.dart';
import 'package:primea/v2/uplink/stream_response.dart';
import 'package:primea/v2/uplink/twitch_stream_card.dart';
import 'package:primea/v2/logo/logo_painter.dart';

class Console extends StatefulWidget {
  final ScrollController scrollController;

  const Console({
    super.key,
    required this.scrollController,
  });

  @override
  State<StatefulWidget> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  StreamResponse? _selectedStream;
  StreamResponse? _hoveredStream;

  late final AnimationController _controller;
  final GlobalKey<AnimatedListState> _streamListState =
      GlobalKey<AnimatedListState>();

  late final Animation<double> _openAnimation;
  late final Animation<double> _textAnimation;

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

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..forward();

    _openAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 1.0, curve: Curves.bounceOut),
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
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: _content,
      builder: (context, snapshot) {
        final child = AnimatedList(
          key: _streamListState,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          initialItemCount: 1,
          // controller: widget.scrollController,
          itemBuilder: (context, index, animation) {
            if (snapshot.connectionState != ConnectionState.done) {
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
                  child: Text("Error: ${snapshot.error}"),
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
                      if (_hoveredStream?.id != element.id) {
                        setState(() {
                          _hoveredStream = element;
                        });
                      }
                    } else {
                      if (_hoveredStream?.id == element.id) {
                        setState(() {
                          _hoveredStream = null;
                        });
                      }
                    }
                  },
                  onTap: () {
                    setState(() {
                      if (_selectedStream?.userId == element.userId) {
                        _selectedStream = null;
                      } else {
                        _selectedStream = element;
                      }
                    });
                  },
                  child: TwitchStreamCard(
                    isHovered: _hoveredStream?.id == element.id,
                    isSelected: _selectedStream?.id == element.id,
                    stream: element,
                  ),
                ),
              ),
            );
          },
        );

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: .5,
                  ),
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: .5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                right: BorderSide(
                                  width: .5,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                ],
              ),
            ),
            SizedBox(
              height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PlayerPanel(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: 250,
                                  minWidth: 175,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow,
                                  border: Border(
                                    left: BorderSide(
                                      width: .5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    right: BorderSide(
                                      width: .5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Icon(
                                        Icons.close,
                                        size: 150,
                                        color: Colors.red.withOpacity(.75),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              fit: FlexFit.tight,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ScaleTransition(
                                      scale: _openAnimation,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          bottom: 16,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: Colors.white.withOpacity(.35),
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
                                              sigmaX: 5,
                                              sigmaY: 5,
                                            ),
                                            blendMode: BlendMode.srcOver,
                                            child: Center(
                                              child: FittedBox(
                                                child: FadeTransition(
                                                  opacity: _textAnimation,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black38,
                                                      border: Border.all(
                                                        color: Colors.red,
                                                        width: 4,
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.all(16),
                                                    child: Text(
                                                      "ACCESS DENIED",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium
                                                          ?.copyWith(
                                                            color: Colors.red,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: .5,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(
                              maxWidth: 250,
                              minWidth: 175,
                            ),
                            decoration: BoxDecoration(
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
                              ),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CustomPaint(
                                painter: LogoPainter(
                                  primaryColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: Text(
                              "PRIMEA",
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 450),
                            child: Text(
                              "Elevate your Parallel game with win rates and meta insights. Track stats, refine your strategy, and lead your parallel to victory.",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(200),
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 0.5,
                                ),
                                right: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 266,
                              child: AnimatedSwitcher(
                                duration: Durations.long4,
                                child: child,
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
            Center(
              child: TwitchEmbed(channel: _selectedStream?.userName),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
