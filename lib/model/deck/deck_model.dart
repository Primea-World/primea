import 'package:primea/main.dart';
import 'package:primea/model/deck/card_function_cache.dart';
import 'package:primea/model/deck/deck.dart';
import 'package:primea/model/deck/card_function.dart';

class DeckModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hidden;
  final List<int> cards;

  const DeckModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.hidden,
    required this.cards,
  });

  DeckModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        createdAt = DateTime.parse(json['created_at']),
        updatedAt = DateTime.parse(json['updated_at']),
        hidden = json['hidden'],
        cards = List<int>.from(json['cards']);

  static Future<DeckModel> fromCode(
    String name,
    String code, {
    String? id,
  }) async {
    final List<int> parsedCodes = List.empty(growable: true);
    final List<String> deck = code.split(',');

    for (var card in deck) {
      final parts = card.split(CardFunction.cardPrefix);
      final count = parts[0].isEmpty ? 1 : int.parse(parts[0].substring(0, 1));
      final cardId = int.parse(parts[1].split(':')[0]);
      parsedCodes.addAll(List.filled(count, cardId));
    }
    if (id == null) {
      return DeckModel.fromJson(
        await supabase
            .from(Deck.decksTableName)
            .insert({
              'name': name,
              'cards': parsedCodes,
            })
            .select()
            .single(),
      );
    } else {
      return DeckModel.fromJson(
        await supabase
            .from(Deck.decksTableName)
            .update({
              'name': name,
              'cards': parsedCodes,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id)
            .select()
            .single(),
      );
    }
  }

  static Future<DeckModel> fromID(String id) async {
    final deckJson =
        await supabase.from(Deck.decksTableName).select().eq('id', id).single();

    return DeckModel.fromJson(deckJson);
  }

  static Future<Iterable<DeckModel>> fetchAll() async {
    final deckJson = await supabase
        .from(Deck.decksTableName)
        .select()
        .eq('hidden', false)
        .order('updated_at', ascending: false);

    return deckJson.map((json) => DeckModel.fromJson(json));
  }

  static Future<Iterable<Deck>> toDeckList(
    Iterable<DeckModel> deckModels,
  ) async {
    final cardIds = deckModels.fold(
      <int>{},
      (acc, deckModel) => acc..addAll(deckModel.cards),
    );
    final cacheResults = CardFunctionCache.getAll(cardIds);

    if (cacheResults.misses.isNotEmpty) {
      final cardFunctionsJson = await supabase
          .from(CardFunction.cardFunctionTableName)
          .select()
          .inFilter('id', cardIds.toList());

      final cardFunctions = Map.fromEntries(
        cardFunctionsJson.map(
          (json) => MapEntry(
            json['id'] as int,
            CardFunction.fromJson(json),
          ),
        ),
      );

      CardFunctionCache.addAll(cardFunctions);
      cacheResults.cardFunctions.addAll(cardFunctions);
    }

    return deckModels.map(
      (deckModel) => Deck(
        id: deckModel.id,
        name: deckModel.name,
        cards: deckModel.cards.map(
          (card) =>
              cacheResults.cardFunctions[card] ?? CardFunction.unknown(card),
        ),
        hidden: deckModel.hidden,
        createdAt: deckModel.createdAt,
        updatedAt: deckModel.updatedAt,
      ),
    );
  }

  Future<Deck> toDeck() async {
    final cacheResults = CardFunctionCache.getAll(cards);

    Map<int, CardFunction> cardFunctions = {};

    if (cacheResults.misses.isNotEmpty) {
      final cardFunctionsJson = await supabase
          .from(CardFunction.cardFunctionTableName)
          .select()
          .inFilter('id', cacheResults.misses);

      cardFunctions = Map.fromEntries(cardFunctionsJson.map(
        (json) => MapEntry(
          json['id'] as int,
          CardFunction.fromJson(json),
        ),
      ));

      // add cached results to cardFunctions
      cardFunctions.addAll(cacheResults.cardFunctions);

      CardFunctionCache.addAll(cardFunctions);
    }

    return Deck(
      id: id,
      name: name,
      cards: cards.map((card) => cardFunctions[card]!),
      hidden: hidden,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Deck toDeckSync(Map<int, CardFunction> cardFunctions) {
    return Deck(
      id: id,
      name: name,
      cards: cards.map((card) => cardFunctions[card]!),
      hidden: hidden,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String toCode() {
    final cardCounts = <int, int>{};
    for (var card in cards) {
      cardCounts.update(card, (value) => value + 1, ifAbsent: () => 1);
    }

    final cardCodes = cardCounts.entries.map((entry) {
      final card = entry.key;
      final count = entry.value;
      return count == 1
          ? "${CardFunction.cardPrefix}$card"
          : '${count}x${CardFunction.cardPrefix}$card';
    });

    return cardCodes.join(',');
  }

  @override
  String toString() {
    return 'DeckModel(name: $name, createdAt: $createdAt, updatedAt: $updatedAt, cards: $cards)';
  }
}
