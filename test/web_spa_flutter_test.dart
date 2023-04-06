import 'package:flutter_test/flutter_test.dart';

import 'package:web_spa_flutter/view/web_spa_widget.dart';

void main() {
  final webSpaWidget = WebSpaWidget(isLocal: false, path: "");
  test('check values', () {
    expect(webSpaWidget.isLocal, false);
    expect(webSpaWidget.path, "");
  });
}
