import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      pages: [
        MaterialPage(
          key: const ValueKey('unknown'),
          child:
              NotFound(goHome: () => setSelectedPage(const PrimeaUplinkPage())),
        ),
        if (_selectedPage is PrimeaUplinkPage)
          PrimeaRoutePage(
            key: ValueKey('uplink'),
            child: Console(
              scrollController: _scrollController,
            ),
          ),
        if (_selectedPage is PrimeaMatchesPage)
          const PrimeaRoutePage(
            key: ValueKey('matches'),
            child: MatchListWidget(),
          ),
        if (_selectedPage is PrimeaConsolePage)
          const PrimeaRoutePage(
            key: ValueKey('console'),
            child: Center(child: Text("console")),
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
