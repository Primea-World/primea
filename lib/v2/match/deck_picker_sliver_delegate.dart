import 'package:flutter/material.dart';
import 'package:primea/v2/match/deck_picker_sliver_header.dart';

class DeckPickerSliverDelegate extends SliverPersistentHeaderDelegate {
  DeckPickerSliverDelegate();

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 200;

  @override
  bool shouldRebuild(DeckPickerSliverDelegate oldDelegate) => false;

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
        child: const DeckPickerSliverHeader(),
      ),
    );
  }
}
