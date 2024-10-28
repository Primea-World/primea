import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:primea/primea.dart';
import 'package:primea/route_information_parser.dart';
import 'package:primea/router_delegate.dart';
import 'package:primea/util/analytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const errorTable = 'errors';

final supabase = Supabase.instance.client;

Future<void> reportError(FlutterErrorDetails details) async {
  await supabase.from(errorTable).insert({
    'error': details.exceptionAsString(),
    'library': details.library,
    'stack': details.stack.toString(),
    'context': details.context.toString(),
  });
}

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Supabase
      await Supabase.initialize(
        url: 'https://fdrysfgctvdtvrxpldxb.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkcnlzZmdjdHZkdHZyeHBsZHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEyNDMyMjgsImV4cCI6MjAzNjgxOTIyOH0.7wcpER7Kch2A9zm5MiTKowd7IQ3Q2jSVkDytGzdTZHU',
        authOptions: const FlutterAuthClientOptions(
          detectSessionInUri: true,
        ),
      );

      supabase.functions.setAuth(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkcnlzZmdjdHZkdHZyeHBsZHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEyNDMyMjgsImV4cCI6MjAzNjgxOTIyOH0.7wcpER7Kch2A9zm5MiTKowd7IQ3Q2jSVkDytGzdTZHU');

      // Set up error handling
      FlutterError.onError = (details) {
        if (kReleaseMode) {
          reportError(details);
        }
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        if (kReleaseMode) {
          reportError(FlutterErrorDetails(exception: error, stack: stack));
        }
        return false;
      };

      runApp(const App(title: 'PRIMEA'));
    },
    (error, stackTrace) {
      final details = FlutterErrorDetails(exception: error, stack: stackTrace);
      if (kReleaseMode) {
        reportError(details);
      }
      FlutterError.presentError(details);
    },
  );
}

class App extends StatefulWidget {
  const App({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late final PrimeaRouterDelegate _routerDelegate;
  late final PrimeaRouteInformationParser _routeInformationParser;

  final ScrollController _scrollController = ScrollController();

  static const _cardTheme = CardTheme(
    shape: ContinuousRectangleBorder(),
  );

  static const _buttonTheme = ButtonThemeData(
    shape: ContinuousRectangleBorder(),
  );

  static const _badgeTheme = BadgeThemeData(
    backgroundColor: Color(0xFFF35A4F),
  );

  static const _iconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        ContinuousRectangleBorder(),
      ),
    ),
  );

  static const _textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        ContinuousRectangleBorder(),
      ),
    ),
  );

  static const _fontFamily = 'Krypton';

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    displayMedium: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    displaySmall: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    headlineLarge: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    headlineMedium: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    headlineSmall: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    titleLarge: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    titleMedium: TextStyle(
      fontVariations: [FontVariation('wght', 500)],
    ),
    titleSmall: TextStyle(
      fontVariations: [FontVariation('wght', 500)],
    ),
    bodyLarge: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    bodyMedium: TextStyle(
      fontVariations: [FontVariation('wght', 600)],
    ),
    bodySmall: TextStyle(
      fontVariations: [FontVariation('wght', 400)],
    ),
    labelLarge: TextStyle(
      fontVariations: [FontVariation('wght', 500)],
    ),
    labelMedium: TextStyle(
      fontVariations: [FontVariation('wght', 500)],
    ),
    labelSmall: TextStyle(
      fontVariations: [FontVariation('wght', 500)],
    ),
  );

  final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFDEF141),
      primary: const Color(0xFFDEF141),
      brightness: Brightness.light,
    ),
    cardTheme: _cardTheme,
    buttonTheme: _buttonTheme,
    badgeTheme: _badgeTheme,
    iconButtonTheme: _iconButtonTheme,
    textButtonTheme: _textButtonTheme,
    fontFamily: _fontFamily,
    textTheme: _textTheme,
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFDEF141),
      primary: const Color(0xFFDEF141),
      brightness: Brightness.dark,
    ),
    cardTheme: _cardTheme,
    buttonTheme: _buttonTheme,
    badgeTheme: _badgeTheme,
    iconButtonTheme: _iconButtonTheme,
    textButtonTheme: _textButtonTheme,
    fontFamily: _fontFamily,
    textTheme: _textTheme,
  );

  @override
  initState() {
    _routerDelegate = PrimeaRouterDelegate(
      _navigatorKey,
      scrollController: _scrollController,
    );
    _routeInformationParser = PrimeaRouteInformationParser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Analytics.instance.trackEvent("load", {"page": "main"});

    return SafeArea(
      child: MaterialApp.router(
        title: widget.title,
        theme: lightTheme,
        darkTheme: darkTheme,
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
        builder: (context, child) {
          return Primea(
            navigatorKey: _navigatorKey,
            scrollController: _scrollController,
            routerDelegate: _routerDelegate,
            title: widget.title,
            body: child,
          );
        },
      ),
    );
  }
}
