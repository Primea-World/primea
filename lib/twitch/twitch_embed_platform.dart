import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TwitchEmbed extends StatefulWidget {
  static const double aspectRatio = 4 / 3;

  final String parentSource;

  final int width, height;
  final String? channel;

  TwitchEmbed({
    super.key,
    required this.channel,
    this.width = 400,
  })  : height = (width / aspectRatio).round(),
        parentSource = kDebugMode ? 'localhost' : 'primea.world';

  @override
  State<StatefulWidget> createState() => _TwitchEmbedState();
}

class _TwitchEmbedState extends State<TwitchEmbed> {
  int loadingProgress = 0;

  // final WebViewController _webViewController = WebViewController()
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted);

  // web.HTMLElement registerRedDivFactory() {
  //   return web.HTMLIFrameElement()
  //     ..id = 'twitch-iframe-${widget.channel}'
  //     ..src =
  //         'https://player.twitch.tv/?${widget.channel}&parent=${widget.parentSource}'
  //     ..width = widget.width.toString()
  //     ..height = widget.height.toString()
  //     ..allowFullscreen = true;
  // }

  @override
  void initState() {
    super.initState();
//     _webViewController
//         .setNavigationDelegate(
//       NavigationDelegate(
//         onWebResourceError: (error) => print('Web resource error: $error'),
//         onProgress: (progress) {
//           print('Loading progress: $progress');
//           setState(() {
//             loadingProgress = progress;
//           });
//         },
//         onHttpAuthRequest: (request) => print('HTTP auth request: $request'),
//         onHttpError: (error) {
//           print('HTTP error: ${error.toString()}');
//         },
//       ),
//     )
//         .then((_) {
//       // src="https://player.twitch.tv/?channel=${widget.channel}&parent=${widget.parentSource}"
//       return _webViewController.loadHtmlString(
//           '''<div id="twitch-iframe-${widget.channel}" style="background-color: #FFFF00;">HI</div>
// ''');
//     }).then((_) {
//       return _webViewController
//           .loadRequest(Uri.parse("https://player.twitch.tv/js/embed/v1.js"));
//     }).then((_) async {
//       await _webViewController.runJavaScript('''
// console.log('Twitch embed script loaded');
// // var player = new Twitch.Player("twitch-iframe-${widget.channel}", {'channel': '${widget.channel}', 'parent': 'localhost'});
// ''');
//     });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.channel == null) {
      return ConstrainedBox(
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
      );
    }

    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: 720,
        ),
        child: AspectRatio(
          aspectRatio: TwitchEmbed.aspectRatio,
          child: Container(),
        ),
      ),
    );
  }
}
