import 'package:flutter/material.dart';
import 'package:primea/util/relative_time.dart';
import 'package:primea/v2/uplink/stream_response.dart';

class TwitchStreamCard extends StatelessWidget {
  final bool isHovered, isSelected;
  final StreamResponse stream;

  const TwitchStreamCard({
    super.key,
    required this.isHovered,
    required this.isSelected,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Card(
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          shadowColor: Theme.of(context).colorScheme.primary,
          elevation: isHovered ? 8 : 4,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 320,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.zero,
              border: Border.all(
                width: 2,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
            padding: EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  stream.thumbnailUrl
                      .toString()
                      .replaceFirst("%7Bwidth%7D", "320")
                      .replaceFirst("%7Bheight%7D", "180"),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return SizedBox(
                      width: 320,
                      height: 180,
                      child: LinearProgressIndicator(
                        value: loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1 << 6),
                      ),
                    );
                  },
                  width: 320,
                  height: 180,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: 4,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          child: Text(
                            stream.language.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: stream.userName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                Text(
                  formatRelativeTime(
                    DateTime.now().toUtc().difference(stream.startedAt),
                  ),
                  textScaler: TextScaler.linear(.75),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  stream.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 0,
          child: Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              stream.viewerCount.toString(),
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ],
    );
  }
}
