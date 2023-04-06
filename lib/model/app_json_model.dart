import 'package:web_spa_flutter/model/display_model.dart';
import 'package:web_spa_flutter/model/header_model.dart';
import 'package:web_spa_flutter/model/menu_model.dart';

// 読み込んだJsonを格納するクラス。
// ここの中身によって、アプリで表示する中身が変る。
class AppJsonModel {

  static const String _keyHeader = "header";
  static const String _keyMenu = "menu";
  static const String _keyDisplays = "displays";
  final HeaderModel? headerModel;
  final MenuModel? menuModel;
  final List<DisplayModel>? displayModels;

  AppJsonModel({required this.headerModel, required this.menuModel, required this.displayModels});

  factory AppJsonModel.fromJson(Map<String, dynamic> json) {
    List<DisplayModel> displayModels = [];
    for (Map<String, dynamic> displaysJson in json[_keyDisplays]) {
      displayModels.add(DisplayModel.fromJson(displaysJson));
    }
    return AppJsonModel(
        headerModel: json[_keyHeader] == null ? null : HeaderModel.fromJson(json[_keyHeader]),
        menuModel: json[_keyMenu] == null ? null : MenuModel.fromJson(json[_keyMenu]),
        displayModels: displayModels,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> displaysJson = [];
    displayModels?.forEach((displayModel) {
      displaysJson.add(displayModel.toJson());
    });
    return {
      _keyHeader: headerModel?.toJson(),
      _keyMenu: menuModel?.toJson(),
      _keyDisplays: displaysJson
    };
  }
}
