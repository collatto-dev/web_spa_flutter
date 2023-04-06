library web_spa_flutter;

class DisplayModel {
  static const String _keyDisplayId = "display_id";
  static const String _keyType = "type";
  static const String _keyContents = "contents";

  String? displayId;
  DisplayType? type;
  List<ContentModel>? contentModels;

  DisplayModel({this.displayId, this.type, this.contentModels});

  factory DisplayModel.fromJson(Map<String, dynamic> json) {
    return DisplayModel(
        displayId: json[_keyDisplayId],
        type: _toDisplayType(json),
        contentModels: _createContentModels(json),
    );
  }

  toJson() {
    List<Map<String, dynamic>> contentsJson = [];
    contentModels?.forEach((contentModel) {
      contentsJson.add(contentModel.toJson());
    });
    return {
      _keyDisplayId: displayId,
      _keyType: type?.toString(),
      _keyContents: contentsJson,
    };
  }

  static DisplayType? _toDisplayType(Map<String, dynamic> json) {
    final type = json[_keyType];
    // デフォルト設定ではWebViewで表示する。
    if (type == null) {
      return DisplayType.web_view;
    }

    try {
      return DisplayType.values.byName(type);
    } catch (e) {
      return null;
    }
  }

  static List<ContentModel>? _createContentModels(Map<String, dynamic> json) {
    final contentsJson = json[_keyContents];
    if (contentsJson == null) {
      return null;
    }

    List<ContentModel> contentModels = [];
    for (Map<String, dynamic> contentJson in contentsJson) {
      contentModels.add(ContentModel.fromJson(contentJson));
    }
    return contentModels;
  }
}

// web_views: アプリ内のWebViewで表示
// web_views: 外部ブラウザで表示
// original_contents: ユーザーが独自に作成したコンテンツを表示
enum DisplayType {
  web_view,
  external_browser,
  original_contents,
}

class ContentModel {

  static const String _keyContentType = "type";
  static const String _keyUrl = "url";
  static const String _keyLinks = "links";

  ContentType? contentType;
  String? url;
  List<Link>? links;

  ContentModel({this.contentType, this.url, this.links});

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      contentType: _toContentType(json),
      url: json[_keyUrl],
      links: _createLinkModels(json),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> linksJson = [];
    links?.forEach((link) {
      linksJson.add(link.toJson());
    });

    return {
      _keyContentType: contentType,
      _keyUrl: url,
      _keyLinks: linksJson,
    };
  }

  static ContentType? _toContentType(Map<String, dynamic> json) {
    final type = json[_keyContentType];
    // デフォルト設定ではWebViewで表示する。
    if (type == null) {
      return ContentType.outer_web_file;
    }

    try {
      return ContentType.values.byName(type);
    } catch (e) {
      return null;
    }
  }

  static List<Link>? _createLinkModels(Map<String, dynamic> json) {
    final linksJson = json[_keyLinks];
    if (linksJson == null) {
      return null;
    }

    List<Link> linkModels = [];
    for (Map<String, dynamic> linkJson in json[_keyLinks]) {
      linkModels.add(Link.fromJson(linkJson));
    }
    return linkModels;
  }
}

// outer_web_file: 外部からhtmlを読み込む際に使用(https://xxxx)
// inner_web_file: アプリ内にあるhtmlを読み込む際に使用(file:///)
// network_web_view: 独自コンテンツである画像を読み込む際に使用(https://xxxx)
enum ContentType {
  outer_web_file,
  inner_web_file,
  network_web_view,
}

class Link {
  static const String _keyType = "type";
  // TODO: Use _keyTriggerId when touch original content.
  // TODO: Don't implement.
  static const String _keyTriggerUrl = "trigger_url";
  static const String _keyReferenceTarget = "reference_target";

  String? triggerUrl;
  AccessType? accessType;
  String? referenceTarget;

  Link({
    this.triggerUrl,
    this.accessType,
    this.referenceTarget});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      triggerUrl: json[_keyTriggerUrl],
      accessType: _toAccessType(json),
      referenceTarget: json[_keyReferenceTarget],
    );
  }

  Map<String, dynamic> toJson() => {
    _keyTriggerUrl: triggerUrl,
    _keyType: accessType?.toString(),
    _keyReferenceTarget: referenceTarget,
  };

  static AccessType? _toAccessType(Map<String, dynamic> json) {
    final type = json[_keyType];
    // デフォルト設定ではWebViewで表示する。
    if (type == null) {
      return AccessType.display;
    }

    try {
      return AccessType.values.byName(type);
    } catch (e) {
      return null;
    }
  }
}

enum AccessType {
  display,
  external_browser,
  web_view,
}
