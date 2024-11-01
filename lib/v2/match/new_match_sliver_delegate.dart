import 'package:flutter/material.dart';
import 'package:primea/v2/match/new_match_sliver_header.dart';

class NewMatchSliverDelegate extends SliverPersistentHeaderDelegate {
  NewMatchSliverDelegate();

  @override
  double get maxExtent => 550;

  @override
  double get minExtent => 550;

  @override
  bool shouldRebuild(NewMatchSliverDelegate oldDelegate) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          minHeight: minExtent,
          maxHeight: maxExtent,
          maxWidth: 740,
        ),
        padding: const EdgeInsets.all(8),
        child: NewMatchSliverHeader(
          shrinkOffset: shrinkOffset,
          overlapsContent: overlapsContent,
        ),
      ),
    );
  }
}
