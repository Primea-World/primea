import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class TwitchEmbed extends StatelessWidget {
  static const double aspectRatio = 16 / 9;

  final String parentSource;

  final int width, height;
  final String? channel;
  final String viewType;

  TwitchEmbed({
    super.key,
    required this.channel,
    this.width = 400,
  })  : height = (width / aspectRatio).round(),
        viewType = 'twitch-iframe-$channel',
        parentSource = kDebugMode ? 'localhost' : 'primea.world' {
    registerTwitchIFrameFactory();
  }

  void registerTwitchIFrameFactory() {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId, {Object? params}) {
        final web.HTMLIFrameElement iframe = web.HTMLIFrameElement()
          ..id = viewType
          ..src = Uri.parse(
                  'https://player.twitch.tv/?channel=$channel&parent=$parentSource')
              .toString()
          ..style.width = "100%"
          ..style.height = "100%"
          ..allow = "fullscreen";
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (channel == null) {
      return MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: 720,
          ),
          child: AspectRatio(
            aspectRatio: TwitchEmbed.aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2A0845),
                    Color(0xFF6441A5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Text(
                    'STREAM: DISCONNECTED',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: 720,
      ),
      child: AspectRatio(
        aspectRatio: TwitchEmbed.aspectRatio,
        child: HtmlElementView(
          viewType: viewType,
        ),
      ),
    );
  }
}
