import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:primea/model/match/match_model.dart';
import 'package:primea/model/match/match_result_option.dart';
import 'package:primea/model/season/season.dart';
import 'package:primea/util/breakpoint.dart';
import 'package:primea/v2/match/labeled_value.dart';
import 'package:vector_graphics/vector_graphics.dart';

class PlayerPanel extends StatefulWidget {
  final String? user;
  final Season? season;
  final Iterable<MatchModel>? matches;

  const PlayerPanel({
    super.key,
    this.user,
    this.season,
    this.matches,
  });

  @override
  State<StatefulWidget> createState() => _PlayerPanelState();
}

class _PlayerPanelState extends State<PlayerPanel> {
  late final seasonImage = AssetBytesLoader(
    "assets/parallel_logos/vec/${widget.season?.parallel.title}.svg.vec",
  ).loadBytes(context);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          flex: 3,
          child: Container(
            constraints:
                BoxConstraints(maxWidth: Breakpoint.tablet.width - 120),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  blurRadius: 24,
                  offset: Offset(8, 8),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 36,
              top: 30,
              right: 24,
              bottom: 24,
            ),
            child: InkWell(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 16,
                    right: 0,
                    child: SvgPicture(
                      width: 100,
                      height: 100,
                      AssetBytesLoader(
                        "assets/parallel_logos/vec/${widget.season?.parallel.title ?? 'universal'}.svg.vec",
                      ),
                      colorFilter: ColorFilter.mode(
                        widget.season?.parallel.color.withAlpha(150) ??
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(100),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      Icons.arrow_circle_right,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'USER: ',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              TextSpan(
                                text: widget.user ?? "[UNKNOWN]",
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              TextSpan(
                                text: '\n',
                              ),
                              TextSpan(
                                text: 'SEASON: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w100,
                                    ),
                              ),
                              TextSpan(
                                text: widget.season?.name ?? "[UNKNOWN]",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Table(
                        children: [
                          // TableRow(
                          //   children: [
                          //     TableCell(
                          //       child: FittedBox(
                          //         fit: BoxFit.scaleDown,
                          //         alignment: Alignment.centerLeft,
                          //         child: LabeledValue(
                          //           label: 'RANK',
                          //           value: 'UNRANKED',
                          //           borderColor:
                          //               Theme.of(context).colorScheme.primary,
                          //         ),
                          //       ),
                          //     ),
                          //     TableCell(
                          //       child: FittedBox(
                          //         fit: BoxFit.scaleDown,
                          //         alignment: Alignment.centerLeft,
                          //         child: LabeledValue(
                          //           label: 'MMR',
                          //           value: '0',
                          //           borderColor:
                          //               Theme.of(context).colorScheme.primary,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          TableRow(
                            children: [
                              TableCell(
                                child: LabeledValue(
                                  label: "MATCHES",
                                  value:
                                      (widget.matches?.length ?? 0).toString(),
                                  borderColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w100,
                                      ),
                                  valueStyle:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                              ),
                              TableCell(
                                child: LabeledValue(
                                  label: "MATCHES (7D)",
                                  value: (widget.matches?.fold(
                                              0,
                                              (acc, match) => acc += match
                                                      .matchTime
                                                      .isAfter(DateTime.now()
                                                          .subtract(Duration(
                                                              days: 7)))
                                                  ? 1
                                                  : 0) ??
                                          0)
                                      .toString(),
                                  borderColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w100,
                                      ),
                                  valueStyle:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              TableCell(
                                child: LabeledValue(
                                  label: "MATCHES WON",
                                  value: (widget.matches?.fold(
                                              0,
                                              (acc, match) => acc +=
                                                  match.result ==
                                                          MatchResultOption.win
                                                      ? 1
                                                      : 0) ??
                                          0)
                                      .toString(),
                                  borderColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w100,
                                      ),
                                  valueStyle:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                              ),
                              TableCell(
                                child: LabeledValue(
                                  label: "MATCHES LOST",
                                  value: (widget.matches?.fold(
                                              0,
                                              (acc, match) => acc +=
                                                  match.result ==
                                                          MatchResultOption.loss
                                                      ? 1
                                                      : 0) ??
                                          0)
                                      .toString(),
                                  borderColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w100,
                                      ),
                                  valueStyle:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).pushNamed("/matches");
              },
            ),
          ),
        ),
        Expanded(
          flex: MediaQuery.of(context).size.width < Breakpoint.desktop.width
              ? 2
              : 3,
          child: Container(),
        ),
      ],
    );
  }
}
