import 'package:primea/model/deck/card_expansion.dart';
import 'package:primea/model/deck/card_rarity.dart';
import 'package:primea/model/deck/card_subtype.dart';
import 'package:primea/model/deck/card_type.dart';
import 'package:primea/tracker/paragon.dart';

class CardFunction {
  static const String cardFunctionTableName = 'card_functions';
  static const String cardPrefix = 'CB-';

  int id;
  String basename;
  String title;
  ParallelType parallel;
  CardRarity rarity;
  String functionText;
  String flavourText;
  String? passiveAbility;
  int cost;
  int attack;
  int health;
  CardType cardType;
  CardSubtype? subtype;
  CardExpansion expansion;

  CardFunction({
    required this.id,
    required this.basename,
    required this.title,
    required this.parallel,
    required this.rarity,
    required this.functionText,
    required this.flavourText,
    this.passiveAbility,
    required this.cost,
    required this.attack,
    required this.health,
    required this.cardType,
    this.subtype,
    required this.expansion,
  });

  CardFunction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        basename = json['basename'],
        title = json['title'],
        parallel = ParallelType.values.byName(json['parallel']),
        rarity = CardRarity.values.byName(json['rarity']),
        functionText = json['function_text'],
        flavourText = json['flavour_text'],
        passiveAbility = json['passive_ability'],
        cost = json['cost'],
        attack = json['attack'],
        health = json['health'],
        cardType = CardType.fromName(json['card_type']),
        subtype = json['subtype'] != null
            ? CardSubtype.values.byName(json['subtype'])
            : null,
        expansion = CardExpansion.fromName(json['expansion']);

  CardFunction.unknown(int card)
      : id = card,
        basename = "CB-$card",
        title = 'Unknown',
        parallel = ParallelType.universal,
        rarity = CardRarity.common,
        functionText = 'Unknown',
        flavourText = 'Unknown',
        cost = 0,
        attack = 0,
        health = 0,
        cardType = CardType.unit,
        expansion = CardExpansion.baseSet;
}
