import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:primea/v2/console/console.dart';
import 'package:primea/v2/profile/profile.dart';
import 'package:primea/primea_route_page.dart';
import 'package:primea/route_information_parser.dart';
import 'package:primea/v2/uplink/uplink.dart';
import 'package:primea/v2/match/match_list.dart';
import 'package:primea/v2/not_found.dart';

class PrimeaRouterDelegate extends RouterDelegate<PrimeaRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PrimeaRoutePath> {
  final GlobalKey<NavigatorState> _navigatorKey;
  final ScrollController _scrollController;

  PrimeaRouterDelegate(GlobalKey<NavigatorState> key,
      {required ScrollController scrollController})
      : _navigatorKey = key,
        _scrollController = scrollController;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  PrimeaPage _selectedPage = const PrimeaUplinkPage();

  PrimeaPage get selectedPage => _selectedPage;

  void setSelectedPage(covariant PrimeaPage page) {
    _selectedPage = page;
    notifyListeners();
  }

  @override
  PrimeaRoutePath get currentConfiguration {
    return PrimeaRoutePath(
      page: _selectedPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case '/uplink':
            setSelectedPage(const PrimeaUplinkPage());
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => Uplink(
                scrollController: _scrollController,
              ),
            );
          case '/matches':
            setSelectedPage(const PrimeaMatchesPage());
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => MatchListWidget(),
            );
          case '/console':
            setSelectedPage(const PrimeaConsolePage());
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => Console(),
            );
          case '/profile':
            setSelectedPage(const PrimeaProfilePage());
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => Profile(),
            );
          default:
            setSelectedPage(const PrimeaUnknownPage());
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => NotFound(
                goHome: () => setSelectedPage(
                  const PrimeaUplinkPage(),
                ),
              ),
            );
        }
      },
      pages: [
        MaterialPage(
          key: const ValueKey('unknown'),
          child:
              NotFound(goHome: () => setSelectedPage(const PrimeaUplinkPage())),
        ),
        if (_selectedPage is PrimeaUplinkPage)
          PrimeaRoutePage(
            key: ValueKey('uplink'),
            child: Uplink(
              scrollController: _scrollController,
            ),
          ),
        if (_selectedPage is PrimeaMatchesPage)
          const PrimeaRoutePage(
            key: ValueKey('matches'),
            child: MatchListWidget(),
          ),
        if (_selectedPage is PrimeaProfilePage)
          const PrimeaRoutePage(
            key: ValueKey('matches'),
            child: Profile(),
          ),
        if (_selectedPage is PrimeaConsolePage)
          const PrimeaRoutePage(
            key: ValueKey('console'),
            child: Console(),
          ),
      ],
      onDidRemovePage: (page) {
        navigatorKey.currentState?.widget.pages.remove(page);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PrimeaRoutePath configuration) async =>
      SynchronousFuture(setSelectedPage(configuration.page));
}
