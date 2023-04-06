library web_spa_flutter;

import 'package:flutter/widgets.dart';
import 'package:web_spa_flutter/utils.dart';

class TopMenuState extends ChangeNotifier {
  String displayId = "";

  void updateDisplayId(String? displayId) {
    Utils.log("updateDisplayId: $displayId");
    if (displayId == null ||this.displayId == displayId) {
      return;
    }
    // // prevDisplayIdの役割としては、
    // prevDisplayId = this.displayId;
    this.displayId = displayId;
    notifyListeners();
  }
}