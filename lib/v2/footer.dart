import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primea/v2/echelon_logo.dart/echelon_logo_painter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: .5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 54,
                      child: AspectRatio(
                        aspectRatio: 2,
                        child: CustomPaint(
                          painter: EchelonLogoPainter(
                            primaryColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ECHELON\nFOUNDATION",
                            style: GoogleFonts.chakraPetch(
                              textStyle: Theme.of(context).textTheme.labelLarge,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  "OFFICIAL PARTNER",
                  style: GoogleFonts.chakraPetch(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    fontWeight: FontWeight.w100,
                  ).copyWith(
                    letterSpacing: 2.1,
                  ),
                ),
              ],
            ),
            Text(
              "Primea World © 2024",
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
