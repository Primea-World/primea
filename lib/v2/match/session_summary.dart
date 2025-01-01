import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/v2/border/echelon_border.dart';
import 'package:primea/v2/match/labeled_value.dart';

class SessionSummary extends StatefulWidget {
  final Iterable<MatchModel> session;
  final void Function(bool isExpanded) onExpansionChanged;

  const SessionSummary({
    super.key,
    required this.session,
    required this.onExpansionChanged,
  });

  @override
  State<StatefulWidget> createState() => _SessionSummaryState();
}

class _SessionSummaryState extends State<SessionSummary>
    with TickerProviderStateMixin {
  late final AnimationController _expandedIndicatorController =
      AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );
  late final Animation<double> _expandedIndicatorAnimation = Tween(
    begin: 0.0,
    end: 0.5,
  ).animate(CurvedAnimation(
    parent: _expandedIndicatorController,
    curve: Curves.linear,
  ));

  late final AnimationController _winRateController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  late final Animation<Color?> _winRateColor = ColorTween(
    begin: Colors.amber,
    end: Colors.green,
  ).animate(CurvedAnimation(
    parent: _winRateController,
    curve: Curves.linear,
  ));

  @override
  void initState() {
    super.initState();
    _winRateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _expandedIndicatorController.dispose();
    _winRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _winRateController.animateTo(
      widget.session.fold(
            0,
            (acc, match) =>
                acc += match.result == MatchResultOption.win ? 1 : 0,
          ) /
          widget.session.length,
      duration: const Duration(milliseconds: 500),
    );

    return InkWell(
      onTap: () {
        if (!_expandedIndicatorController.isAnimating) {
          widget.onExpansionChanged(_expandedIndicatorController.isDismissed);
          _expandedIndicatorController.isDismissed
              ? _expandedIndicatorController.forward()
              : _expandedIndicatorController.reverse();
        }
      },
      customBorder: EchelonBorder(
        radius: const Radius.circular(8),
        left: const BorderSide(
          color: Colors.transparent,
          width: 0.5,
        ),
        right: const BorderSide(
          color: Colors.transparent,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: LabeledValue(
                          borderColor: const Color(0xaaff7433),
                          label: "session date",
                          value: DateFormat.MMMd()
                              .format(widget.session.first.matchTime.toUtc()),
                        ),
                      ),
                    ),
                    TableCell(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: LabeledValue(
                          borderColor: const Color(0xaaC2E7FF),
                          label: "mmr",
                          value: widget.session
                              .fold(
                                  0, (acc, match) => acc += match.mmrDelta ?? 0)
                              .toString(),
                        ),
                      ),
                    ),
                    TableCell(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: LabeledValue(
                          borderColor: const Color(0xaa43ff64),
                          label: "matches",
                          value: widget.session.length.toString(),
                        ),
                      ),
                    ),
                  ],
                ),
                const TableRow(
                  children: [
                    TableCell(child: SizedBox(height: 8)),
                    TableCell(child: SizedBox(height: 8)),
                    TableCell(child: SizedBox(height: 8)),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: LabeledValue(
                          borderColor: const Color(0xaab694ff),
                          label: "win - loss",
                          value:
                              "${widget.session.fold(0, (acc, match) => acc += match.result == MatchResultOption.win ? 1 : 0)}-${widget.session.fold(0, (acc, match) => acc += match.result == MatchResultOption.loss ? 1 : 0)}",
                        ),
                      ),
                    ),
                    TableCell(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: LabeledValue(
                          borderColor: const Color(0xaadff141),
                          label: "1st - 2nd",
                          value:
                              "${widget.session.fold(0, (acc, match) => acc += match.playerTurn == PlayerTurn.going1st ? 1 : 0)}-${widget.session.fold(0, (acc, match) => acc += match.playerTurn == PlayerTurn.going2nd ? 1 : 0)}",
                        ),
                      ),
                    ),
                    const TableCell(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox.square(
                dimension: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          valueColor: _winRateColor,
                          value: _winRateController.value,
                        ),
                      ),
                    ),
                    Text(
                      "${(_winRateController.value * 100).toStringAsFixed(0)}%",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Text(
                "win rate".toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          RotationTransition(
            turns: _expandedIndicatorAnimation,
            child: const Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
    );
  }
}
