import 'package:flutter/foundation.dart';
import 'package:primea/main.dart';
import 'package:primea/model/deck/card_function.dart';
import 'package:primea/model/deck/card_function_cache.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/deck_model.dart';

class DeckList extends ChangeNotifier {
  DeckList({Iterable<Deck> decks = const []}) : _decks = decks;

  Iterable<Deck> _decks;

  Iterable<Deck> get decks => _decks;

  Future<Deck?> findDeck(String id) async {
    try {
      return _decks.firstWhere(
        (element) => element.id == id,
      );
    } on StateError catch (_) {
      return await _fetchDeck(id);
    }
  }

  static Future<DeckList> fromJson(List<Map<String, dynamic>> json) async {
    final requiredCards = json.fold(
      <int>{},
      (acc, deck) => acc
        ..addAll(
          (deck['cards'] as List<dynamic>).map(
            (c) => c as int,
          ),
        ),
    );
    final cardCacheResults = CardFunctionCache.getAll(requiredCards);

    if (cardCacheResults.misses.isNotEmpty) {
      final Map<int, CardFunction> fetchedCards = await supabase
          .from(CardFunction.cardFunctionTableName)
          .select()
          .inFilter('id', cardCacheResults.misses)
          .then(
        (value) {
          final funcs = value.map(CardFunction.fromJson);
          return {
            for (final func in funcs) func.id: func,
          };
        },
      );

      CardFunctionCache.addAll(fetchedCards);
      cardCacheResults.cardFunctions.addAll(fetchedCards);
    }

    return DeckList(decks: json.map((e) {
      return DeckModel.fromJson(e).toDeckSync(cardCacheResults.cardFunctions);
    }));
  }

  Future<Deck?> _fetchDeck(String id) async {
    final deckModel = await supabase
        .from(Deck.decksTableName)
        .select()
        .eq('id', id)
        .limit(1)
        .then((result) => result.map(DeckModel.fromJson));

    if (deckModel.isEmpty) {
      return null;
    }
    final deck = await deckModel.first.toDeck();
    _decks = _decks.followedBy([deck]);
    return deck;
  }

  void addDeck(Deck deck) {
    _decks.followedBy([deck]);
    notifyListeners();
  }

  void removeDeck(Deck deck) {
    _decks = _decks.where((element) => element != deck);
    notifyListeners();
  }
}
