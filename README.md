# load_spa_application

jsonファイルに書かれた内容を表示するpackageです。  
メニューの作成、コンテンツの表示を行うことができます。  
表示するコンテンツとして、htmlを読み込み画面上に表示させます。  

---

## Getting Started

1. 本パッケージを読み込みます。
2. [json](#jsonについて)ファイルを作成します。  
3. jsonファイルをassetsに配置します。  
   または、Webサーバーに配置します。  
   例）assets/app.json   
4. import
5. WebSpaWidgetを初期化します。  
   例）assetsから取得する場合、`isLocal: true`, `path: "assets/app.json"`
   　　Webサーバから取得する場合、`isLocal: false`, `path: "http://xxxx"` 
  ```yaml
  const WebSpaWidget(isLocal: true, path: "assets/json/app.json")
  ```

---

## 実装例

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WebSpaWidget(isLocal: true, path: "assets/json/app.json"),
      // home: const WebSpaWidget(isLocal: false, path: "https://xxxx"),
    );
  }
}
```

---

## jsonについて

```json
{
    "header": {
        "icon": {
            "url": "http://xxxx",
            "width": 40,
            "height": 40
        },
        "title": "example",
        "background_color": "FF99E9EA"
    },
    "menu": {
        "type": "bottom_menu",
        "background_color": "FF99E9EA",
        "selected_text_color": "FF3F48CC",
        "unselected_text_color": "FF000000",
        "items": [
            {
                "name": "menu1",
                "icon": {
                    "url": "http://xxxx",
                    "width": 40,
                    "height": 40
                },
                "display_id": "display1",
                "order": 1
            },
            {
                "name": "menu2",
                "icon": {
                    "url": "http://xxxx",
                    "width": 40,
                    "height": 40
                },
                "display_id": "display2",
                "order": 2
            },
            {
                "name": "menu3",
                "icon": {
                    "url": "http://xxxx",
                    "width": 40,
                    "height": 40
                },
                "display_id": "display3",
                "order": 3
            },
            {
                "name": "menu4",
                "icon": {
                    "url": "http://xxxx",
                    "width": 40,
                    "height": 40
                },
                "display_id": "display4",
                "order": 4
            }
        ]
    },
    "displays": [
        {
            "display_id": "display1",
            "type": "web_view",
            "contents": [
                {
                    "type": "outer_web_file",
                    "url": "https://pub.dev/"
                }
            ]
        },
        {
            "display_id": "display2",
            "type": "web_view",
            "contents": [
                {
                    "type": "outer_web_file",
                    "url": "https://dart.dev/"
                }
            ]
        },
        {
            "display_id": "display3",
            "type": "external_browser",
            "contents": [
                {
                    "type": "outer_web_file",
                    "url": "https://dart.dev/"
                }
            ]
        },
        {
            "display_id": "display4",
            "type": "web_view",
            "contents": [
                {
                    "type": "inner_web_file",
                    "url": "assets/html/test.html",
                    "links": [
                        {
                            "trigger_url": "https://pub.dev/",
                            "type": "display",
                            "reference_target": "display1"
                        },
                        {
                            "trigger_url": "https://fuchsia.dev/",
                            "type": "web_view",
                            "reference_target": "https://dart.dev/"
                        },
                        {
                            "trigger_url": "https://flutter.dev/",
                            "type": "external_browser",
                            "reference_target": "https://flutter.dev/"
                        }
                    ]
                }
            ]
        }
    ]
}
```


---

## **header**

| key              | value                                                                            |
| ---------------- | -------------------------------------------------------------------------------- |
| [icon](#icon)    | ヘッダーに表示するアイコンの情報。                                               |
| title            | ヘッダーに表示するタイトル名<br>, iconが存在しない場合に表示する<br>文字列で表記 |
| background_color | ヘッダーの背景色<br>, 16進数のargbで表記                                         |

```json
{
  "header": {
    "icon": {
      "url": "https://xxxx.png",
      "width": 40,
      "height": 40
    },
    "title": "nanana",
    "background_color": "FFFFF200"
  }
}
```

---

## **icon**

| key    | value                                   |
| ------ | --------------------------------------- |
| url    | アイコン画像の参照先url<br>文字列で表記 |
| width  | アイコンの横幅<br>整数値で表記          |
| height | アイコンの縦幅<br>整数値で表記          |

```json
"icon": {
  "url": "https://xxxx.png",
  "width": 40,
  "height": 40
}
```

---

## **menu**

| key                   | value                                                                                   |
| --------------------- | --------------------------------------------------------------------------------------- |
| type                  | メニューのタイプを選択する<br>下メニュー: `bottom_menu`<br>横メニュー: `left_side_menu` |
| background_color      | メニューの背景色<br>16進数のargbで表記                                                  |
| unselected_text_color   | 選択中のメニューの文字色                                                                |
| unselected_text_color | 非選択のメニューの文字色                                                                |
| [items](#items)       | メニューに表示する要素の一覧                                                            |

```json
"menu": {
  "type": "navigation_menu",
  "background_color": "FFFFF200",
  "items": [
    {
      "name": "menu1",
      "icon": {
        "url": "https://xxxx.png",
        "width": 40,
        "height": 40
      },
      "display_id": "display1",
      "order": 1
    }
  ]
},

```

---

## **items**

| key           | value                                                                                               |
| ------------- | --------------------------------------------------------------------------------------------------- |
| name          | メニュー名<br>文字列で表記                                                                          |
| [icon](#icon) | メニューに表示するアイコン                                                                          |
| display_id    | メニューをタップした際に表示する画面のid<br>[display](#display)の`display_id`を使用文字列で表記<br> |
| order         | メニュー内での表示位置<br>1が最初の要素<br>整数値で表記                                             |

```json
{
  "items": [
    {
      "name": "menu1",
      "icon": {
        "url": "https://xxxx.png",
        "width": 40,
        "height": 40
      },
      "display_id": "display1",
      "order": 1
    },
    {
      "name": "menu2",
      "icon": {
        "url": "https://xxxx.png",
        "width": 40,
        "height": 40
      },
      "display_id": "display2",
      "order": 2
    }
  ]
}
```

---

## **display**

| key                   | value                                                                                                  |
| --------------------- | ------------------------------------------------------------------------------------------------------ |
| display_id            | [items](#items)と連動するユニークid<br>文字列で表記                                                    |
| type                  | WebView表示: `web_view`<br>外部ブラウザ表示: `external_browser`                                        |
| [contents](#contents) | WebView, 外部ブラウザにてコンテンツを表示する<br>TODO:将来的には複数コンテンツの表示ができるようにする |

```json
{
  "display": [
    {
      "display_id": "display1",
      "type": "web_view",
      "contents": [
        {
          "type": "inner_web_file",
          "url": "file://xxxxx.html"
        }
      ]
    },
    {
      "display_id": "display2",
      "type": "external_browser",
    }
  ]  
}
```

---

## **contents**

| key             | value                                                                                                                                |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| type            | 外部htmlを表示: `outer_web_file`,アプリ内htmlを表示: `inner_web_file`<br>※外部ブラウザ表示は、`outer_web_file`の場合のみ可能         |
| url             | 表示するコンテンツのurl                                                                                                              |
| [links](#links) | WebView上で特定のurlのページにアクセスした際の動作を設定<br>`network_image_view`を使用している場合は、画像をタップした時の動作を定義 |

```json
{
  "contents": [
    {
      "type": "outer_web_file",
      "url": "https://xxxxx",
      "links": []
    },
    {
      "url": "https://xxxxx"
    },
  ]
}
```

---

## **links**

| key              | value                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------- |
| trigger_url      | トリガーとなるurl<br>※リダイレクト先のurlを指定し、`external_browser`を使用しないこと |
| type             | `trigger_url`にアクセスした際の動作タイプ<br>`display`,`external_browser`, `web_view` |
| reference_target | `trigger_url`にアクセスした際の参照先<br>画面遷移は`display_id`, Web表示は`url`を入力 |

※ `trigger_url`が重複する場合、<br>
　 reference_display_id > reference_web_view_url > reference_external_browser_urlの優先順位で動作する。

```json
{
  "links": [
    {
        "trigger_url": "https://xxxxx",
        "type": "display",
        "reference_target": "display1"
    },
    {
        "trigger_url": "https://xxxxx",
        "type": "external_browser",
        "reference_target": "https://xxxxx"
    },
    {
        "trigger_url": "https://xxxxx",
        "type": "web_view",
        "reference_target": "https://xxxxx"
    }
  ]
}
```