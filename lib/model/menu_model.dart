library web_spa_flutter;

import 'package:web_spa_flutter/model/icon_model.dart';

class MenuModel {

  static const String _keyType = "type";
  static const String _keyItems = "items";
  static const String _keyBackgroundColor = "background_color";
  static const String _keySelectedTextColor = "selected_text_color";
  static const String _keyUnselectedTextColor = "unselected_text_color";

  final MenuType? type;
  final List<ItemModel>? items;
  final String? backgroundColor;
  final String? selectedTextColor;
  final String? unselectedTextColor;

  MenuModel({
    this.type,
    this.items,
    this.backgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    List<ItemModel> itemModels = [];
    for (Map<String, dynamic> itemJson in json[_keyItems]) {
      itemModels.add(ItemModel.fromJson(itemJson));
    }
    _sortByOrder(itemModels);

    return MenuModel(
        type: _toMenuType(json),
        items: itemModels,
        backgroundColor: json[_keyBackgroundColor],
        selectedTextColor: json[_keySelectedTextColor] ?? "FF3F48CC",
        unselectedTextColor: json[_keyUnselectedTextColor] ?? "FF000000"
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> itemsJson = [];
    items?.forEach((ItemModel item) {
      for (ItemModel item in items!) {
        itemsJson.add(item.toJson());
      }
    });

    return {
      _keyType : type?.toString(),
      _keyItems : itemsJson,
      _keyBackgroundColor: backgroundColor,
      _keySelectedTextColor: selectedTextColor,
      _keyUnselectedTextColor: unselectedTextColor
    };
  }

  static MenuType? _toMenuType(Map<String, dynamic> json) {
    final type = json[_keyType];
    if (type == null) {
      return MenuType.bottom_menu;
    }

    try {
      return MenuType.values.byName(type);
    } catch (e) {
      return null;
    }
  }

  static void _sortByOrder(List<ItemModel> itemModels) {
    itemModels.sort((prev, next) {
      if (prev.order == null) {
        return itemModels.length - 1;
      }
      if (next.order == null) {
        return itemModels.length - 1;
      }
      return prev.order!.compareTo(next.order!);
    });
  }

  int? searchIndex(String displayId) {
    try {
      if (items == null) {
        return null;
      }
      for (int index = 0; index < items!.length; index++) {
        if (items![index].displayId == displayId) {
          return index;
        }
      }
    } catch (e) {
      print("searchOrder Exception: $e");
      return null;
    }
    return null;
  }

  String? searchDisplayId(int index) {
    if (items == null) {
      return null;
    }
    // itemsは昇順でソートして、画面上でメニュー表示している。
    // よって、選択したメニューの位置が、itemsの位置と等しい。
    return items![index].displayId;
  }
}

enum MenuType {
  bottom_menu,
  left_side_menu,
}

class ItemModel {

  static const _keyName = "name";
  static const _keyIcon = "icon";
  static const _keyDisplayId = "display_id";
  static const _keyOrder = "order";

  final String? name;
  final IconModel? icon;
  final String? displayId;
  final int? order;

  ItemModel({this.name, this.icon, this.displayId, this.order});

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      ItemModel(
          name: json[_keyName],
          icon: json[_keyIcon] == null ? null : IconModel.fromJson(json[_keyIcon]),
          displayId: json[_keyDisplayId],
          order:json[_keyOrder],
      );

  Map<String, dynamic> toJson() => {
    _keyName: name,
    _keyIcon: icon?.toJson(),
    _keyDisplayId: displayId,
    _keyOrder: order,
  };
}
