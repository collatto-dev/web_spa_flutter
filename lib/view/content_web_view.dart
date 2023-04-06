import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_spa_flutter/change_notifier/top_menu_state.dart';
import 'package:web_spa_flutter/change_notifier/web_navigation_button_state.dart';
import 'package:web_spa_flutter/model/display_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_spa_flutter/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class ContentWebViews extends StatelessWidget {
  const ContentWebViews(
      this.displayModels,
      this.contentModels,
      {Key? key}) : super(key: key);

  // ContentWebViewクラスをトリガーとして画面遷移する際、
  // 画面遷移先が外部ブラウザの要素だったら画面遷移させてはいけないので、
  // 画面遷移先の情報を取得するために使用する。
  // 本来ならこのクラスではList<ContentModel>より上位の層は持たせたくない。
  final List<DisplayModel>? displayModels;
  // ContentWebViewで表示、動作させたい内容の配列を格納している。
  final List<ContentModel>? contentModels;

  @override
  Widget build(BuildContext context) {
    Utils.log("ContentWebView build");
    List<ContentModel>? contentModels = this.contentModels;
    if (contentModels == null || contentModels.isEmpty) {
      return const Text("Don't have contents.");
    }
    return ContentWebView(displayModels, contentModels.first);
  }
}

class ContentWebView extends StatelessWidget {
  const ContentWebView(
      this.displayModels,
      this.contentModel,
      {Key? key}) : super(key: key);

  // ContentWebViewクラスをトリガーとして画面遷移する際、
  // 画面遷移先が外部ブラウザの要素だったら画面遷移させてはいけないので、
  // 画面遷移先の情報を取得するために使用する。
  // 本来ならこのクラスではList<ContentModel>より上位の層は持たせたくない。
  final List<DisplayModel>? displayModels;
  // ContentWebViewで表示、動作させたい内容を格納している。
  final ContentModel contentModel;

  @override
  Widget build(BuildContext context) {
    final webViewController = setupWebViewController(context);
    return Column(children: [
      Flexible(flex: 9, fit: FlexFit.tight, child: FutureBuilder(
          // future: webViewController.loadRequest(Uri.parse(contentModel.url ?? "")),
          future: loadPage(webViewController, contentModel),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return WebViewWidget(controller: webViewController);
            } else {
              return const Text("");
            }
          })),
      // Flexible(flex: 9, fit: FlexFit.tight, child: Text("aa")),
      Flexible(flex: 1,
          fit: FlexFit.tight,
          child: createNavigationBar(webViewController)),
    ]);
  }

  WebViewController setupWebViewController(BuildContext context) {
    WebViewController webViewController = WebViewController();
    if (kIsWeb) {
      // Flutter webはプレビュー専用
      return webViewController;
    }

    final navigationButtonState = Provider.of<WebNavigationButtonState>(context, listen: false);
    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.setBackgroundColor(const Color(0x00000000));
    webViewController.clearCache();
    webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request){
          Utils.log("onNavigationRequest: ${request.url}");
          return checkLink(webViewController, request.url, context);
        },
        onPageStarted: (String url) async {
          Utils.log("onPageStarted: $url");
          bool canGoBack = await webViewController.canGoBack();
          bool canGoForward = await webViewController.canGoForward();
          navigationButtonState.updateState(
              canGoBack: canGoBack, canGoForward: canGoForward);
        },
        onPageFinished: (String url) {
          Utils.log("onPageFinished: $url");
        },
        onWebResourceError: (WebResourceError error) {},
      ),
    );
    return webViewController;
  }

  Future<void> loadPage(WebViewController webViewController, ContentModel contentModel) async {
    switch (contentModel.contentType) {
      case ContentType.outer_web_file:
        return webViewController.loadRequest(Uri.parse(contentModel.url ?? ""));
      case ContentType.inner_web_file:
        String htmlString = await rootBundle.loadString("assets/html/test.html");
        return webViewController.loadHtmlString(htmlString);
      default:
        return Future.value();
    }
  }

  NavigationDecision checkLink(
      WebViewController webViewController,
      String url,
      BuildContext context) {
    final links = contentModel.links;
    if (links == null) {
      return NavigationDecision.navigate;
    }
    for (Link link in links) {
      if (link.triggerUrl == url) {
        // トリガーurlなので、指定した動作を行う。
        switch (link.accessType) {
          case AccessType.display:
            final topMenuState = Provider.of<TopMenuState>(context, listen: false);
            if (link.referenceTarget == null) break;
            // 画面遷移先の要素が外部ブラウザ表示の場合、画面遷移せず外部ブラウザ表示のみ行う必用がある。
            // それ以外の場合はtopMenuStateを更新して画面遷移する。
            DisplayModel? nextDisplayModel = searchDisplay(link.referenceTarget);
            if (nextDisplayModel?.type == DisplayType.external_browser) {
              final url = nextDisplayModel?.contentModels?.first.url;
              if (url == null) return NavigationDecision.prevent;
              // ※リダイレクトの場合は前のWebViewが残ってしまうので注意
              launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            } else {
              topMenuState.updateDisplayId(link.referenceTarget);
            }
            return NavigationDecision.prevent;

          case AccessType.web_view:
            webViewController.loadRequest(Uri.parse(link.referenceTarget ?? ""));
            return NavigationDecision.prevent;

          case AccessType.external_browser:
            // 画面遷移・外部ブラウザ起動なので、ブラウザの表示は変更しない。
            if (link.referenceTarget == null) break;
            launchUrl(
                Uri.parse(link.referenceTarget!),
                mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;

          default:
            return NavigationDecision.navigate;
        }
      }
    }
    return NavigationDecision.navigate;
  }

  Widget createNavigationBar(WebViewController webViewController) {
    return Consumer<WebNavigationButtonState>(
        builder: (context, webNavigationButtonState, child) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    webViewController.canGoBack().then((canGoBack) =>
                        webViewController.goBack()
                    );
                  },
                  child: createNavigationButton(
                      const Icon(Icons.arrow_back_ios),
                      webNavigationButtonState.canGoBack),
                ),
                GestureDetector(
                  onTap: () {
                    webViewController.reload();
                  },
                  child: const Icon(Icons.update),
                ),
                GestureDetector(
                  onTap: () {
                    webViewController.canGoForward().then((canGoForward) =>
                        webViewController.goForward()
                    );
                  },
                  child: createNavigationButton(
                      const Icon(Icons.arrow_forward_ios),
                      webNavigationButtonState.canGoForward),
                ),
              ]
          );
        }
    );
  }

  Widget createNavigationButton(Icon icon, bool state) {
    if (state) {
      return icon;
    } else {
      return Opacity(
          opacity: 0.25,
          child: icon);
    }
  }

  DisplayModel? searchDisplay(String? displayId) {
    if (displayModels == null || displayId == null) return null;
    for (DisplayModel displayModel in displayModels!) {
      if (displayModel.displayId == displayId) {
        return displayModel;
      }
    }
    return null;
  }

}