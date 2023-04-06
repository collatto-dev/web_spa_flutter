library web_spa_flutter;

import 'package:web_spa_flutter/model/icon_model.dart';

class HeaderModel {

  static const String _keyIcon = "icon";
  static const String _keyTitle = "title";
  static const String _keyBackgroundColor = "background_color";

  IconModel? icon;
  String? title;
  String? backgroundColor;

  HeaderModel({this.icon, this.title, this.backgroundColor});

  factory HeaderModel.fromJson(Map<String, dynamic> json) {
    return HeaderModel(
        icon: json[_keyIcon] == null ? null : IconModel.fromJson(json[_keyIcon]),
        title: json[_keyTitle],
        backgroundColor: json[_keyBackgroundColor]
    );
  }

  Map<String, dynamic> toJson() => {
    _keyIcon: icon?.toJson(),
    _keyTitle: title,
    _keyBackgroundColor: backgroundColor,
  };

  // Color? parseBackgroundColor() {
  //   if (backgroundColor == null) return null;
  //   return Color.fromARGB(
  //       int.parse(backgroundColor!.substring(0,2), radix: 16),
  //       int.parse(backgroundColor!.substring(2,4), radix: 16),
  //       int.parse(backgroundColor!.substring(4,6), radix: 16),
  //       int.parse(backgroundColor!.substring(6,8), radix: 16)
  //   );
  // }
}