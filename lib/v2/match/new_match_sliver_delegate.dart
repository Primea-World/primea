import 'package:flutter/material.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/v2/match/new_match_sliver_header.dart';

class NewMatchSliverDelegate extends SliverPersistentHeaderDelegate {
  final Paragon? chosenParagon;
  final String? chosenDeckId;

  NewMatchSliverDelegate(this.chosenParagon, this.chosenDeckId);

  @override
  double get maxExtent => 762;

  @override
  double get minExtent => 762;

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
