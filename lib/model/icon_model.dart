library web_spa_flutter;

class IconModel {

  static const String _keyUrl = "url";
  static const String _keyWidth = "width";
  static const String _keyHeight = "height";

  String? url;
  double? width;
  double? height;

  IconModel({this.url, this.width, this.height});

  factory IconModel.fromJson(Map<String, dynamic> json) {
    return IconModel(
      url: json[_keyUrl],
      width: json[_keyWidth].toDouble(),
      height: json[_keyHeight].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    _keyUrl: url,
    _keyWidth: width,
    _keyHeight: height,
  };
}