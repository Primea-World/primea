import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PrimeaPage {
  String get title;
  String get path => "/${title.toLowerCase()}";

  const PrimeaPage();

  @override
  operator ==(Object other) {
    return other is PrimeaPage && other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class PrimeaUnknownPage extends PrimeaPage {
  const PrimeaUnknownPage();

  @override
  String get title => "UNKNOWN";

  @override
  String get path => "/404";
}

class PrimeaUplinkPage extends PrimeaPage {
  const PrimeaUplinkPage();

  @override
  String get title => "UPLINK";

  @override
  String get path => "/";
}

class PrimeaMatchesPage extends PrimeaPage {
  const PrimeaMatchesPage();

  @override
  String get title => "MATCHES";
}

class PrimeaConsolePage extends PrimeaPage {
  const PrimeaConsolePage();

  @override
  String get title => "CONSOLE";
}

class PrimeaProfilePage extends PrimeaPage {
  const PrimeaProfilePage();

  @override
  String get title => "PROFILE";
}

class PrimeaRoutePath {
  final PrimeaPage page;

  const PrimeaRoutePath({
    required this.page,
  });

  const PrimeaRoutePath.unknown() : page = const PrimeaUnknownPage();

  const PrimeaRoutePath.landing() : page = const PrimeaUplinkPage();

  const PrimeaRoutePath.matches() : page = const PrimeaMatchesPage();

  const PrimeaRoutePath.dashboard() : page = const PrimeaConsolePage();

  const PrimeaRoutePath.profile() : page = const PrimeaProfilePage();
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
      case 'profile':
        return Future.value(const PrimeaRoutePath.profile());
      default:
        return Future.value(const PrimeaRoutePath.unknown());
    }
  }

  @override
  RouteInformation? restoreRouteInformation(PrimeaRoutePath configuration) {
    switch (configuration.page) {
      case PrimeaUplinkPage page:
        return RouteInformation(uri: Uri.parse(page.path));
      case PrimeaMatchesPage page:
        return RouteInformation(uri: Uri.parse(page.path));
      case PrimeaConsolePage page:
        return RouteInformation(uri: Uri.parse(page.path));
      case PrimeaProfilePage page:
        return RouteInformation(uri: Uri.parse(page.path));
      case PrimeaUnknownPage _:
      default:
        return RouteInformation(uri: Uri.parse('/404'));
    }
  }
}
