import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:primea/model/match/player_turn.dart';
import 'package:primea/tracker/paragon.dart';
import 'package:primea/v2/border/echelon_border.dart';
import 'package:vector_graphics/vector_graphics.dart';

class MatchParagon extends StatelessWidget {
  final Paragon paragon;
  final PlayerTurn playerTurn;

  const MatchParagon({
    super.key,
    required this.paragon,
    required this.playerTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      textAlign: TextAlign.center,
      preferBelow: false,
      verticalOffset: 48,
      richMessage: TextSpan(
        children: [
          TextSpan(
            children: [
              if (paragon.title.isNotEmpty)
                TextSpan(
                  text: paragon.title,
                ),
              if (paragon.title.isNotEmpty &&
                  paragon.parallel.name != ParallelType.universal.name)
                const TextSpan(text: '\n'),
              if (paragon.parallel.name != ParallelType.universal.name)
                TextSpan(
                  text: paragon.parallel.title,
                ),
            ],
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (paragon.image == null)
            SvgPicture(
              width: 64,
              height: 64,
              AssetBytesLoader(
                "assets/parallel_logos/vec/${paragon.parallel.name}.svg.vec",
              ),
              colorFilter: ColorFilter.mode(
                paragon.parallel.color,
                BlendMode.srcATop,
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 125),
              margin: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                shape: EchelonBorder(
                  radius: const Radius.circular(8),
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 0.5,
                  ),
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 0.5,
                  ),
                ),
              ),
              child: AspectRatio(
                aspectRatio: 100 / 120,
                child: Image(
                  alignment: Alignment.topCenter,
                  fit: BoxFit.cover,
                  image: AssetImage(paragon.art ?? paragon.image!),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Tooltip(
              message: playerTurn.value ? 'Going 1st' : 'Going 2nd',
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
                child: Icon(
                  playerTurn.value
                      ? Icons.looks_one_rounded
                      : Icons.looks_two_rounded,
                  color: playerTurn.value ? Colors.yellow[600] : Colors.cyan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
