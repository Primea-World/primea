import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class TwitchEmbed extends StatefulWidget {
  static const double aspectRatio = 4 / 3;

  final String parentSource;

  final int width, height;
  final String channel;

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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.width.toDouble() + 20,
        maxHeight: widget.height.toDouble() + 20,
      ),
      child: AspectRatio(
        aspectRatio: TwitchEmbed.aspectRatio,
        child: Container(),
      ),
    );
  }
}
