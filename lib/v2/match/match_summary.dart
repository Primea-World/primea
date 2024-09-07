import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/v2/border/echelon_border.dart';
import 'package:primea/v2/match/match_paragon.dart';

class MatchSummary extends StatefulWidget {
  const MatchSummary({super.key, required this.match});

  final MatchModel match;

  @override
  State<MatchSummary> createState() => _MatchSummaryState();
}

class _MatchSummaryState extends State<MatchSummary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        shape: EchelonBorder(
          radius: const Radius.circular(16),
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 0.5,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: FittedBox(
              child: Text(
                DateFormat.MMMMd()
                    .add_jm()
                    .format(widget.match.matchTime.toLocal()),
                key: ValueKey(widget.match.matchTime),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: FittedBox(
                  child: Column(
                    children: [
                      MatchParagon(
                        paragon: widget.match.paragon,
                        playerTurn: widget.match.playerTurn,
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcATop,
                        shaderCallback: (Rect bounds) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [.1, .5],
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .inverseSurface
                                .withAlpha(100),
                            widget.match.result.color,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          widget.match.result.name.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                            color: widget.match.result.color,
                            shadows: [
                              Shadow(
                                blurRadius: 25,
                                color: widget.match.result.color,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.match.mmrDelta != null)
                        FittedBox(
                          child: Text(
                            "${widget.match.mmrDelta} MMR",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      if (widget.match.primeEarned != null &&
                          widget.match.primeEarned != 0)
                        FittedBox(
                          child: Text(
                            "${widget.match.primeEarned?.toStringAsPrecision(3)} PRIME",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      if (widget.match.deck != null)
                        FittedBox(
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "${widget.match.deck?.name}",
                              // style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  child: MatchParagon(
                    paragon: widget.match.opponentParagon,
                    playerTurn: widget.match.playerTurn == PlayerTurn.going1st
                        ? PlayerTurn.going2nd
                        : PlayerTurn.going1st,
                  ),
                ),
              ),
            ],
          ),
          if (widget.match.opponentUsername != null &&
              widget.match.opponentUsername!.isNotEmpty)
            Center(
              child: FittedBox(
                child: Text(
                  widget.match.opponentUsername!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          if (widget.match.notes != null) Text(widget.match.notes!),
        ],
      ),
    );
  }
}
