import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:primea/route_information_parser.dart';
import 'package:primea/v2/match/match_list.dart';
import 'package:primea/v2/not_found.dart';

class PrimeaRouterDelegate extends RouterDelegate<PrimeaRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PrimeaRoutePath> {
  PrimeaRouterDelegate();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  PrimeaPage _selectedTab = const PrimeaLandingPage();

  void setSelectedPage(covariant PrimeaPage page) {
    _selectedTab = page;
    notifyListeners();
  }

  @override
  PrimeaRoutePath get currentConfiguration {
    return PrimeaRoutePath(
      page: _selectedTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('unknown'),
          child: NotFound(
              goHome: () => setSelectedPage(const PrimeaLandingPage())),
        ),
        if (_selectedTab is PrimeaLandingPage)
          const MaterialPage(
            key: ValueKey('primea'),
            child: Center(child: Text("home")),
          ),
        if (_selectedTab is PrimeaMatchesPage)
          const MaterialPage(
            key: ValueKey('matches'),
            child: MatchListWidget(),
          ),
        if (_selectedTab is PrimeaDashboardPage)
          const MaterialPage(
            key: ValueKey('dashboard'),
            child: Center(child: Text("dashboard")),
          ),
      ],
      onDidRemovePage: (page) {
        navigatorKey.currentState?.widget.pages.remove(page);
        notifyListeners();
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PrimeaRoutePath configuration) async =>
      SynchronousFuture(setSelectedPage(configuration.page));
}
