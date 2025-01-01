import 'package:flutter/material.dart';
// import 'package:primea/inherited_session.dart';

class Console extends StatefulWidget {
  const Console({super.key});

  @override
  State<StatefulWidget> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // final session = InheritedSession.of(context).session;

    return ListView(
      children: [
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            Container(
              constraints: BoxConstraints(
                minWidth: 200,
                minHeight: 200,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "+/- MMR",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 200),
              child: Text(
                "+/- PRIME",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 200),
              child: Text(
                "Avg. length",
                textAlign: TextAlign.center,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 200),
              child: Text(
                "Fav Paragon",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            Text(
              "Matches/Day",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            Text(
              "Augencore",
              textAlign: TextAlign.center,
            ),
            Text(
              "Earthen",
              textAlign: TextAlign.center,
            ),
            Text(
              "Kathari",
              textAlign: TextAlign.center,
            ),
            Text(
              "Marcolian",
              textAlign: TextAlign.center,
            ),
            Text(
              "Shroud",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            Text(
              "Paragon 1",
              textAlign: TextAlign.center,
            ),
            Text(
              "Paragon 2",
              textAlign: TextAlign.center,
            ),
            Text(
              "Paragon 3",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
