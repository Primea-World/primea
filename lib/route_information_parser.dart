import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PrimeaPage {
  const PrimeaPage();

  static PrimeaPage fromIndex(int index) {
    switch (index) {
      case 0:
        return const PrimeaLandingPage();
      case 1:
        return const PrimeaMatchesPage();
      case 2:
        return const PrimeaDashboardPage();
      default:
        return const PrimeaUnknownPage();
    }
  }

  static int? toIndex(PrimeaPage page) {
    switch (page) {
      case PrimeaLandingPage _:
        return 0;
      case PrimeaMatchesPage _:
        return 1;
      case PrimeaDashboardPage _:
        return 2;
      default:
        return null;
    }
  }
}

class PrimeaUnknownPage extends PrimeaPage {
  const PrimeaUnknownPage();
}

class PrimeaLandingPage extends PrimeaPage {
  const PrimeaLandingPage();
}

class PrimeaMatchesPage extends PrimeaPage {
  const PrimeaMatchesPage();
}

class PrimeaDashboardPage extends PrimeaPage {
  const PrimeaDashboardPage();
}

class PrimeaRoutePath {
  final PrimeaPage page;

  const PrimeaRoutePath({
    required this.page,
  });

  const PrimeaRoutePath.unknown() : page = const PrimeaUnknownPage();

  const PrimeaRoutePath.landing() : page = const PrimeaLandingPage();

  const PrimeaRoutePath.matches() : page = const PrimeaMatchesPage();

  const PrimeaRoutePath.dashboard() : page = const PrimeaDashboardPage();
}

class PrimeaRouteInformationParser
    extends RouteInformationParser<PrimeaRoutePath> {
  @override
  Future<PrimeaRoutePath> parseRouteInformation(
      RouteInformation routeInformation) {
    final path = routeInformation.uri.pathSegments;
    if (kDebugMode) {
      print("${routeInformation.uri} - $path");
    }
    if (path.isEmpty) {
      return Future.value(const PrimeaRoutePath.landing());
    }

    switch (path.first) {
      // case 'auth':
      //   return Future.value(const PrimeaRoutePath.landing());
      case 'matches':
        return Future.value(const PrimeaRoutePath.matches());
      case 'dashboard':
        return Future.value(const PrimeaRoutePath.dashboard());
      default:
        return Future.value(const PrimeaRoutePath.unknown());
    }
  }

  @override
  RouteInformation? restoreRouteInformation(PrimeaRoutePath configuration) {
    switch (configuration.page) {
      case PrimeaLandingPage _:
        return RouteInformation(uri: Uri.parse("/"));
      case PrimeaMatchesPage _:
        return RouteInformation(uri: Uri.parse('/matches'));
      case PrimeaDashboardPage _:
        return RouteInformation(uri: Uri.parse('/dashboard'));
      case PrimeaUnknownPage _:
      default:
        return RouteInformation(uri: Uri.parse('/404'));
    }
  }
}
