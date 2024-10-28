import 'package:flutter/widgets.dart';

class TwitchEmbed extends StatelessWidget {
  final int width;
  final String? channel;

  const TwitchEmbed({
    super.key,
    required this.channel,
    this.width = 400,
  });

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError('TwitchEmbed  not supported on this platform');
  }
}
