import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GameArticleSite extends StatefulWidget {
  const GameArticleSite({super.key});

  @override
  State<GameArticleSite> createState() => _GameArticleSiteState();
}


class _GameArticleSiteState extends State<GameArticleSite> {

  List siteList = [
    {
      "name": "ファミ通",
      "url": "https://www.famitsu.com/",
      "image": "assets/famitsu.png"
    },
    {
      "name": "4gamer",
      "url": "https://www.4gamer.net/",
      "image": "assets/4gamer.net.png"
    },
    {
      "name": "gameSpark",
      "url": "https://www.gamespark.jp/",
      "image": "assets/gamespark.png"
    },
    {
      "name": "gameWatch",
      "url": "https://game.watch.impress.co.jp/",
      "image": "assets/gamewatch.png"
    },
    {
      "name": "AppBank",
      "url": "https://www.appbank.net/category/iphone-application/iphone-games",
      "image": "assets/appbank.png"
    },
  ];

  bool isAppDisplay = true;

  /// 外部サイトへ遷移する
  Future _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future init() async {
    await SharedPrefe.init();
    setState(() {
      isAppDisplay = SharedPrefe.getIsAppDisplay();
    });
  }

  @override
  void initState() {
    init();
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      appBar: MyAppBar(title: "ゲームニュースサイト一覧"),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "アプリ内で表示する",
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                  Switch(
                    value: isAppDisplay,
                    onChanged: (bool value) {
                      setState(() {
                        isAppDisplay = value;
                        print(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // controller: _scrollController,
                itemCount: siteList.length,
                // itemExtent: 150.0,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      SharedPrefe.setIsAppDisplay(isAppDisplay);
                      if (isAppDisplay) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext _context) => WebViewStack(
                              title: siteList[index]["name"],
                              url: siteList[index]["url"],
                            ),
                          ),
                        );
                      } else {
                        _launchUrl(Uri.parse(siteList[index]["url"]));
                      }
                    },
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: 30,
                                    child: Text(
                                      siteList[index]["name"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   height: 30,
                                  //   child: Image.asset(siteList[index]["image"])
                                  // )
                                  // Expanded(
                                  //   flex: 2,
                                  //   child: Image.asset(siteList[index]["image"]),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // バナー広告
            AdModBanner(adModHight: 50),
          ],
        ),
      )
    );
  }
}


// 参考: https://codelabs.developers.google.com/codelabs/flutter-webview?hl=ja#0
class WebViewStack extends StatefulWidget {

  String title;
  String url;

  WebViewStack({
    Key? key,
    required this.title,
    required this.url
  }) : super(key: key);

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;

  final controller = Completer<WebViewController>();

  bool _isLoading = false;

    @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) {
    //   WebView.platform = SurfaceAndroidWebView();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: widget.title,
        actions: [
          NavigationControls(controller: controller, url: widget.url),
        ],
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            // jsを有効化
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (webViewController) {
              controller.complete(webViewController);
            },
            onPageStarted: (url) {
              setState(() {
                loadingPercentage = 0;
              });
            },
            onProgress: (progress) {
              setState(() {
                loadingPercentage = progress;
              });
            },
            onPageFinished: (url) {
              setState(() {
                loadingPercentage = 100;
              });
            },
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}


// webview版のappBarメニュー
class NavigationControls extends StatelessWidget {

  NavigationControls({
    required this.controller,
    required this.url,
    Key? key
    })
      : super(key: key);

  final Completer<WebViewController> controller;

  final String url;

  /// 外部サイトへ遷移する
  Future _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Unable to launch url $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller.future,
      builder: (context, snapshot) {
        final WebViewController? controller = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done ||
            controller == null) {
          return Row(
            children: const[
              Icon(Icons.arrow_back_ios),
              Icon(Icons.arrow_forward_ios),
              Icon(Icons.replay),
              Icon(Icons.ios_share_sharp),
            ],
          );
        }

        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 18,
              constraints: const BoxConstraints(),
              // padding: EdgeInsets.zero,
              onPressed: () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              iconSize: 18,
              constraints: const BoxConstraints(),
              // padding: EdgeInsets.zero,
              onPressed: () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              iconSize: 18,
              constraints: const BoxConstraints(),
              // padding: EdgeInsets.zero,
              onPressed: () {
                controller.reload();
              },
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              iconSize: 18,
              constraints: const BoxConstraints(),
              // padding: EdgeInsets.zero,
              onPressed: () {
                _launchUrl(Uri.parse(url));
              },
            ),
          ],
        );
      },
    );
  }
}


