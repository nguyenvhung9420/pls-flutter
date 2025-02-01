import 'package:pls_flutter/presentation/models/multi_item.dart';

class Composite {
  String? name;
  String? weight;

  String? singleItem;
  MultiItem? multiItem;
  bool isMulti;

  bool isInteractionTerm;
  String? iv;
  String? moderator;

  Composite({
    required this.name,
    required this.weight,
    required this.singleItem,
    required this.multiItem,
    required this.isMulti,
    required this.isInteractionTerm,
    required this.iv,
    required this.moderator,
  });

  String makeCompositeCommandString() {
    String? compositeName = name;
    String? itemPrefix = multiItem?.prefix;
    String? singleItemName = singleItem;
    String range = "${multiItem?.from}:${multiItem?.to}";
    String itemString = "";
    String finalString = "";
    String weightModeB = weight == "mode_B" ? ", weights = mode_B" : "";

    if (isInteractionTerm) {
      itemString = 'interaction_term(iv = "${iv}", moderator = "${moderator}", method = two_stage)';
      finalString = itemString;
    } else if (isMulti) {
      itemString = 'multi_items("$itemPrefix", $range)';
      finalString = 'composite("$compositeName", $itemString $weightModeB)';
    } else {
      itemString = 'single_item("$singleItemName")';
      finalString = 'composite("$compositeName", $itemString $weightModeB)';
    }
    return finalString;
  }
}
