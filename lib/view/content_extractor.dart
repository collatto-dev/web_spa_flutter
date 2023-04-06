import 'package:web_spa_flutter/model/app_json_model.dart';
import 'package:web_spa_flutter/model/display_model.dart';
import 'package:web_spa_flutter/model/menu_model.dart';
import 'package:url_launcher/url_launcher.dart';

mixin ContentExtractor {

  ItemModel? extractItemModel(AppJsonModel appJsonModel, int menuIndex) {
    final menuModel = appJsonModel.menuModel;
    if (menuModel == null) {
      return null;
    }

    final items = menuModel.items;
    if (items == null || items.isEmpty) {
      return null;
    }

    return items[menuIndex];
  }

  DisplayModel? extractDisplayModel(AppJsonModel appJsonModel, int menuIndex) {
    final displayId = extractItemModel(appJsonModel, menuIndex)?.displayId;
    final displayModels = appJsonModel.displayModels;
    if (displayModels == null) return null;
    for (DisplayModel displayModel in displayModels) {
      if (displayModel.displayId != null &&
          displayModel.displayId == displayId) {
        return displayModel;
      }
    }
    return null;
  }

  List<ContentModel>? extractContentModels(ItemModel? itemModel, List<DisplayModel>? displayModels) {
    if (itemModel == null || displayModels == null || displayModels.isEmpty) {
      return null;
    }

    for (DisplayModel displayModel in displayModels) {
      if (displayModel.displayId != null &&
          displayModel.displayId == itemModel.displayId) {
        return displayModel.contentModels;
      }
    }
    return null;
  }

  String extractContentUrl(ItemModel? itemModel, List<DisplayModel>? displayModels) {
    if (itemModel == null || displayModels == null || displayModels.isEmpty) {
      return "";
    }

    for (DisplayModel displayModel in displayModels) {
      if (displayModel.displayId != null &&
          displayModel.displayId == itemModel.displayId) {
        return extractUrls(displayModel).first;
      }
    }
    return "";
  }

  // TODO: このクラスの役割からはずれるため、クラス分け要検討
  bool launchExternalWebView(AppJsonModel appJsonModel, int menuIndex) {
    final displayId = extractItemModel(appJsonModel, menuIndex)?.displayId;
    final displayModels = appJsonModel.displayModels;
    if (displayModels == null) return false;
    for (DisplayModel displayModel in displayModels) {
      if (displayModel.displayId != null &&
          displayModel.displayId == displayId &&
          displayModel.type == DisplayType.external_browser) {
        // DisplayType.external_browserの場合、コンテンツは1個なので最初の要素を取得
        final url = displayModel.contentModels?.first.url;
        if (url == null) return false;
        launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication);
        return true;
      }
    }
    return false;
  }

  // int searchFirstTargetAtWebView(AppJsonModel appJsonModel) {
  //   final displayModels = appJsonModel.displayModels;
  //   if (displayModels == null) throw Exception;
  //   for (DisplayModel displayModel in displayModels) {
  //     if (displayModel.type == BrowserType.web_views) {
  //
  //       final itemModels = appJsonModel.menuModel?.items;
  //       if (itemModels == null) throw Exception;
  //       for (ItemModel itemModel in itemModels) {
  //         if () {
  //
  //         }
  //       }
  //     }
  //   }
  // }
  //
  // String searchDisplayModel() {
  //
  // }

  // String getContentUrl(List<ItemModel> itemModels, List<DisplayModel>? displayModels, int menuIndex) {
  //   if (displayModels == null || displayModels.isEmpty) {
  //     return "";
  //   }
  //
  //   for (DisplayModel displayModel in displayModels) {
  //     if (displayModel.displayId != null &&
  //         displayModel.displayId == itemModels[menuIndex].displayId) {
  //       return getUrls(displayModel)[0];
  //     }
  //   }
  //   return "";
  // }

  List<String> extractUrls(DisplayModel displayModel) {
    final contentModels = displayModel.contentModels;
    if (contentModels == null || contentModels.isEmpty) {
      return [];
    }

    List<String> urls= [];
    for (ContentModel contentModel in contentModels) {
      final url = contentModel.url;
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  List<Link> getLink(DisplayModel displayModel) {
    return [];
  }

  // Widget createContentWebView(AppJsonModel appJsonModel, int menuIndex) {
  //
  // }

}