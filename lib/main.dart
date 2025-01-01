import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
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
      if (kIsWeb) {
        usePathUrlStrategy();
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: 'https://fdrysfgctvdtvrxpldxb.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZkcnlzZmdjdHZkdHZyeHBsZHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjEyNDMyMjgsImV4cCI6MjAzNjgxOTIyOH0.7wcpER7Kch2A9zm5MiTKowd7IQ3Q2jSVkDytGzdTZHU',
        authOptions: const FlutterAuthClientOptions(
          detectSessionInUri: true,
        ),
      );

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

  static const _iconButtonTheme = IconButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        ContinuousRectangleBorder(),
      ),
    ),
  );

  static const _filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        ContinuousRectangleBorder(),
      ),
    ),
  );

  static const _outlinedButtonTheme = OutlinedButtonThemeData(
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

  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFDEF141),
      primary: const Color(0xFFDEF141),
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
      brightness: Brightness.light,
    ),
    cardTheme: _cardTheme,
    buttonTheme: _buttonTheme,
    iconButtonTheme: _iconButtonTheme,
    textButtonTheme: _textButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
  );

  ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFDEF141),
      primary: const Color(0xFFDEF141),
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
      brightness: Brightness.dark,
    ),
    cardTheme: _cardTheme,
    buttonTheme: _buttonTheme,
    iconButtonTheme: _iconButtonTheme,
    textButtonTheme: _textButtonTheme,
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.fuchsia: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.linux: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.macOS: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.windows: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  );

  @override
  initState() {
    _routerDelegate = PrimeaRouterDelegate(
      _navigatorKey,
      scrollController: _scrollController,
    );
    _routeInformationParser = PrimeaRouteInformationParser();

    lightTheme = lightTheme.copyWith(
        textTheme: GoogleFonts.chakraPetchTextTheme(lightTheme.textTheme));
    darkTheme = darkTheme.copyWith(
        textTheme: GoogleFonts.chakraPetchTextTheme(darkTheme.textTheme));

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
