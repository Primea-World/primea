import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/match_result_option.dart';

class SessionSummary extends StatelessWidget {
  const SessionSummary({
    super.key,
    required this.session,
  });

  final List<MatchModel> session;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: Text(
                DateFormat.MMMd().format(session.first.matchTime.toUtc()),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text(
              "${session.fold(0, (acc, match) => acc += match.result == MatchResultOption.win ? 1 : 0)}-${session.fold(0, (acc, match) => acc += match.result == MatchResultOption.loss ? 1 : 0)}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              "${session.fold(0, (acc, match) => acc += match.mmrDelta ?? 0).toString()} MMR",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
