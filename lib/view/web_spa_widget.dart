import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_spa_flutter/change_notifier/top_menu_state.dart';
import 'package:web_spa_flutter/change_notifier/web_navigation_button_state.dart';
import 'package:web_spa_flutter/model/app_json_model.dart';
import 'package:web_spa_flutter/model/header_model.dart';
import 'package:web_spa_flutter/model/menu_model.dart';
import 'package:web_spa_flutter/utils.dart';
import 'package:web_spa_flutter/view/content_extractor.dart';
import 'package:web_spa_flutter/view/content_web_view.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class WebSpaWidget extends StatelessWidget {
  const WebSpaWidget({
    required this.isLocal,
    required this.path,
    super.key});

  final bool isLocal;
  final String path;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TopMenuState()),
        ChangeNotifierProvider(create: (context) => WebNavigationButtonState())
      ],
      child: WebSpaContentsWidget(isLocal: isLocal, path: path),
    );
  }
}

class WebSpaContentsWidget extends StatefulWidget {

  const WebSpaContentsWidget({
    required this.isLocal,
    required this.path,
    super.key
  });

  final bool isLocal;
  final String path;

  @override
  State<StatefulWidget> createState() => _WebSpaContentsWidgetState();
}

class _WebSpaContentsWidgetState extends State<WebSpaContentsWidget> with ContentExtractor {

  Future<String>? appJson;

  @override
  void initState() {
    super.initState();
    // build関数で初期化するとloadJsonが2回呼ばれるため、ここで初期化する
    appJson = loadJson();
  }

  Future<String> loadJson() {
    if (widget.isLocal) {
      // ローカルファイルのapp.jsonを読み込む。
      return loadLocalJson();
    } else {
      // Web上に格納されているapp.jsonを読み込む。
      return loadExternalJson();
    }
  }

  Future<String> loadLocalJson() {
    Utils.log("loadExternalJson");
    Utils.log("path: ${widget.path}");
    if (widget.path.isEmpty) {
      return rootBundle.loadString("assets/json/app.json");
    } else {
      return rootBundle.loadString(widget.path);
    }
  }

  Future<String> loadExternalJson() async {
    Utils.log("loadExternalJson");
    Utils.log("path: ${widget.path}");
    final response = await http.get(Uri.parse(widget.path));
    return utf8.decode(response.bodyBytes);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: appJson,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            try {
              AppJsonModel appJsonModel = AppJsonModel.fromJson(
                  json.decode(snapshot.data!));
              return createMainContent(appJsonModel, context);
            } catch (e) {
              print(e);
            }
            return const Text("app.jsonが正しくありません");
          } else {
            return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                )
            );
          }
        }
    );
  }

  // このアプリの根幹部分を作成。
  Widget createMainContent(AppJsonModel appJsonModel, BuildContext context) {
    final topMenuState = Provider.of<TopMenuState>(context, listen: false);
    return Consumer<TopMenuState>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: createAppBar(appJsonModel),
          drawer: createDrawer(appJsonModel, topMenuState, context),
          body: Center(
            child: ContentWebViews(
                appJsonModel.displayModels,
                extractContentModels(
                    extractItemModel(appJsonModel,
                        appJsonModel.menuModel?.searchIndex(topMenuState.displayId) ?? 0),
                    appJsonModel.displayModels
                )
            ),
          ),
          bottomNavigationBar: createBottomNavigationBar(appJsonModel, topMenuState),
        );
      },
    );
  }

  AppBar? createAppBar(AppJsonModel appJsonModel) {
    final headerModel = appJsonModel.headerModel;
    if (headerModel == null) {
      return null;
    } else {
      return AppBar(
        title: createTitleWidget(headerModel),
        centerTitle: true,
        backgroundColor: Utils.parseBackgroundColor(headerModel.backgroundColor),
      );
    }
  }

  Widget createTitleWidget(HeaderModel headerModel) {
    if (headerModel.icon == null) {
      return Text(headerModel.title ?? "");
    } else {
      return Image.network(
        headerModel.icon?.url ?? "",
        width: headerModel.icon?.width ?? 20,
        height: headerModel.icon?.height ?? 20,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace) {
          return Text(headerModel.title ?? "");
        },);
    }
  }

  // 左開きのドロワーを作成する。
  Drawer? createDrawer(
      AppJsonModel appJsonModel,
      TopMenuState topMenuState,
      BuildContext context) {
    MenuModel? menuModel = appJsonModel.menuModel;
    if (menuModel == null ||
        menuModel.type != MenuType.left_side_menu) {
      return null;
    }

    List<Widget> drawerItems = [];
    menuModel.items?.asMap().forEach((index, item) {
      drawerItems.add(
          GestureDetector(
            onTap: () {
              if (!launchExternalWebView(appJsonModel, index)) {
                Navigator.pop(context);
                // topMenuState.updateMenuIndex(index);
                topMenuState.updateDisplayId(menuModel.searchDisplayId(index));
              }
            },
            // child: createDrawerItem(item, topMenuState.menuIndex == index),
            child: createDrawerItem(
                item,
                menuModel.searchIndex(topMenuState.displayId) == index),
          )
      );
    });
    return Drawer(
      backgroundColor: Utils.parseBackgroundColor(menuModel.backgroundColor),
      child: ListView(
        children: drawerItems,
      ),
    );
  }

  // ドロワーに表示するアイテムを作成する。
  ListTile createDrawerItem(ItemModel itemModel, bool selected) {
    Image? iconImage = createMenuImage(itemModel);
    Text? name = Text(itemModel.name ?? "");
    return ListTile(
      leading: iconImage,
      title: name,
      selected: selected,
    );
  }

  // app.jsonにmenuモデルのデータが無ければ表示させない。
  // BottomNavigationBarはデフォルトで使用する設定。
  BottomNavigationBar? createBottomNavigationBar(
      AppJsonModel appJsonModel,
      TopMenuState topMenuState) {
    // app.jsonのmenuのtypeでbottom_menuを表示する設定になってる場合のみ表示させる。
    MenuModel? menuModel = appJsonModel.menuModel;
    if (menuModel == null || menuModel.type != MenuType.bottom_menu) {
      return null;
    }
    List<BottomNavigationBarItem> bottomNavigationBarItems = [];
    menuModel.items?.forEach((item) {
      bottomNavigationBarItems.add(BottomNavigationBarItem(
        icon: createMenuImage(item),
        label: item.name,
      ));
    });
    if (bottomNavigationBarItems.isEmpty) {
      return null;
    } else {
      return BottomNavigationBar(
        currentIndex: menuModel.searchIndex(topMenuState.displayId) ?? 0,
        backgroundColor: Utils.parseBackgroundColor(menuModel.backgroundColor),
        selectedItemColor: Utils.parseBackgroundColor(menuModel.selectedTextColor),
        unselectedItemColor: Utils.parseBackgroundColor(menuModel.unselectedTextColor),
        onTap: (int index) {
          // 外部ブラウザは画面扱いではない。
          // 外部ブラウザで起動しない場合のみタブを選択させる。
          if (!launchExternalWebView(appJsonModel, index)) {
            // topMenuState.updateMenuIndex(value);
            topMenuState.updateDisplayId(menuModel.searchDisplayId(index));
          }
        },
        items: bottomNavigationBarItems,
        type: BottomNavigationBarType.fixed,
      );
    }
  }

  Image createMenuImage(ItemModel itemModel) {
    return Image.network(
        itemModel.icon?.url ?? "",
        width: itemModel.icon?.width ?? 20,
        height: itemModel.icon?.height ?? 20,
        errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace) {
          return const Icon(Icons.ac_unit);
        });
  }
}
