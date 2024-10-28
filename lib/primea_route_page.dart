import 'package:flutter/material.dart';

class PrimeaRoutePage extends MaterialPage {
  const PrimeaRoutePage({super.key, required super.child});

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) {
        return child;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeInTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );

        var fadeOutTween = Tween(
          begin: 1.0,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
        );

        return FadeTransition(
          opacity: fadeOutTween,
          child: FadeTransition(
            opacity: fadeInTween,
            child: child,
          ),
        );
      },
    );
  }
}
