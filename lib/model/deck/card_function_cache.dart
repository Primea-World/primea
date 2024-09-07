import 'package:primea/model/deck/card_function.dart';

class CardFunctionCacheResults {
  final Map<int, CardFunction> cardFunctions;
  final List<int> misses;

  CardFunctionCacheResults()
      : cardFunctions = {},
        misses = [];
}

class CardFunctionCache {
  static final Map<int, CardFunction> _cache = {};

  static CardFunction? get(int id) {
    return _cache[id];
  }

  static Map<int, CardFunction> getCardFunctions(Iterable<int> cardIds) {
    return cardIds.fold({}, (acc, cardId) {
      if (_cache.containsKey(cardId)) {
        acc[cardId] = _cache[cardId]!;
      }
      return acc;
    });
  }

  static void set(CardFunction cardFunction) {
    _cache[cardFunction.id] = cardFunction;
  }

  static CardFunctionCacheResults getAll(Iterable<int> cardIds) {
    final results = CardFunctionCacheResults();
    for (var cardId in cardIds) {
      if (_cache.containsKey(cardId)) {
        results.cardFunctions[cardId] = _cache[cardId]!;
      } else {
        results.misses.add(cardId);
      }
    }
    return results;
  }

  static void addAll(Map<int, CardFunction> cardFunctions) {
    _cache.addAll(cardFunctions);
  }
}
