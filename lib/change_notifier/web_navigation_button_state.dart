library web_spa_flutter;

import 'package:flutter/widgets.dart';

class WebNavigationButtonState extends ChangeNotifier {
  bool canGoBack = false;
  bool canGoForward = false;

  void updateState({bool? canGoBack, bool? canGoForward}) {
    bool needUpdate = false;
    if (canGoBack != null) {
      if (this.canGoBack != canGoBack) {
        needUpdate = true;
      }
      this.canGoBack = canGoBack;
    }
    if (canGoForward != null) {
      if (this.canGoForward != canGoForward) {
        needUpdate = true;
      }
      this.canGoForward = canGoForward;
    }
    if (needUpdate) {
      notifyListeners();
    }
  }
}