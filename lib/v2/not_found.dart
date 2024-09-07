import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  final Function() goHome;
  const NotFound({
    super.key,
    required this.goHome,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "404",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            "The page you are looking for is not here.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          TextButton(
            child: const Text("Go Home"),
            onPressed: () {
              goHome();
            },
          ),
        ],
      ),
    );
  }
}
