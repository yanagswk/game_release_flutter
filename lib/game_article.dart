import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_article.dart';
import 'package:release/widget/common/drawer_widget.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class GameArticle extends StatefulWidget {
  const GameArticle({super.key});

  Size get preferredSize => Size.fromHeight(45.0);

  @override
  State<GameArticle> createState() => _GameArticleState();
}

class _GameArticleState extends State<GameArticle> with AutomaticKeepAliveClientMixin {
  // 記事一覧
  List<GameArticleModel> articles = [];

  // 記事数
  int articleCount = 0;
  // 取得するゲーム数
  int articleLimit = 50;
  // 取得するゲームの開始位置
  int articleOffset = 0;

  // サイト
  int? _site = null;

  // appBarタイトル
  String _appTitle = "ゲームニュース記事";

  // 投稿タイプ new or target
  String _postType = "new";

  // 指定投稿日
  String _post = "";

  String targetYear = "";
  String targetMonth = "";
  String targetDay = "";

  final nowDate = DateTime.now();

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  


  String getSiteAppTitle() {
    if (_site == 1) {
      return "4gamer";
    } else if (_site == 2) {
      return "ファミ通";
    } else {
      return "ゲームニュース記事";
    }
  }

  String? getPostDateAppTitle() {
    if (_postType == "target") {
      return _post;
    }
    return "";
  }

  Future init(bool isReset) async {
    await SharedPrefe.init();

    if (isReset) {
      setState(() {
        articles = [];
      });
      articleOffset = 0;
      articleCount = 0;
      SharedPrefe.setIsPaging(true);
    }

    // 総数よりも大きくなったらreturnする
    if (articleCount != 0 && articleCount < articleOffset) {
      SharedPrefe.setIsPaging(false);
      return ;
    }

    _gameGetx.setLoading(true);

    final articleModel = await ApiClient().getGameArticle(
      postType: _postType,
      postDate: _post,
      siteId: _site,
      limit: articleLimit,
      offset: articleOffset,
    );
    articleCount = articleModel["article_count"];
    articles.addAll(articleModel["article"]);
    articleOffset += articleLimit;

    setState(() {
      articles;
      _appTitle = "${getSiteAppTitle()} ${getPostDateAppTitle()}";
    });

    _gameGetx.setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    targetYear = now.year.toString();
    targetMonth = now.month.toString();
    targetDay = now.day.toString();
    _post = "${targetYear}/${targetMonth}/${targetDay}";

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      init(true);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: MyAppBar(title: _appTitle),
      drawer: const DrawerWidget(), // サイドバー
      body: GameArticleInfinityView(
        articles: articles,
        getContents: init,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        backgroundColor: Colors.blue[800],
        onPressed: () {
          showModalBottomSheet(
            //モーダルの背景の色、透過
            backgroundColor: Colors.transparent,
            //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, StateSetter setState) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    margin: EdgeInsets.only(top: 64),
                    decoration: BoxDecoration(
                      //モーダル自体の色
                      color: Colors.white,
                      //角丸にする
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.article_outlined),
                              Text(
                                'サイト',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        // crossAxisAlignment:CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              title : Text('全サイト'),
                                              leading: Radio(
                                                activeColor: Colors.blue[900],
                                                groupValue: _site,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _site = value;
                                                  });
                                                },
                                                value: null,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              title : Text('4gamer'),
                                              leading: Radio(
                                                activeColor: Colors.blue[900],
                                                groupValue: _site,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _site = value!;
                                                  });
                                                },
                                                value: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              title : Text('ファミ通'),
                                              leading: Radio(
                                                activeColor: Colors.blue[900],
                                                groupValue: _site,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _site = value!;
                                                  });
                                                },
                                                value: 2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.article_outlined),
                                          Text(
                                            '投稿日',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              title : Text('新着順'),
                                              leading: Radio(
                                                activeColor: Colors.blue[900],
                                                groupValue: _postType,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _postType = value!;
                                                  });
                                                },
                                                value: "new",
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  title : Text('指定する'),
                                                  leading: Radio(
                                                    activeColor: Colors.blue[900],
                                                    groupValue: _postType,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _postType = value!;
                                                      });
                                                    },
                                                    value: "target",
                                                  ),
                                                ),
                                                TextButton(
                                                  style: ButtonStyle(
                                                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                                                    minimumSize: MaterialStateProperty.all(Size.zero),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  child: const Text(
                                                    '日付選択',
                                                    style: TextStyle(color: Colors.blue),
                                                  ),
                                                  onPressed: () {
                                                    DatePicker.showDatePicker(context,
                                                      showTitleActions: true,
                                                      minTime: DateTime(2022, 12, 1),
                                                      maxTime: DateTime(
                                                        int.parse(nowDate.year.toString()),
                                                        int.parse(nowDate.month.toString()),
                                                        int.parse(nowDate.day.toString()),
                                                      ),
                                                      onChanged: (date) {
                                                        // ドラムスクロールで日付を変更した場合に検知。完了ボタンを押してなくても検知する。
                                                        print('change $date');
                                                      },
                                                      onConfirm: (date) {
                                                        // 日付を変更して完了ボタンを押したら検知
                                                        setState(() {
                                                          _postType = "target";
                                                          targetYear = date.year.toString();
                                                          targetMonth = date.month.toString();
                                                          targetDay = date.day.toString();
                                                          _post = "${targetYear}/${targetMonth}/${targetDay}";
                                                        });
                                                      },
                                                      currentTime: DateTime(int.parse(targetYear), int.parse(targetMonth), int.parse(targetDay)),
                                                      locale: LocaleType.jp
                                                    );
                                                }),
                                                Text(_post)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[800], //ボタンの背景色
                                            ),
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                              init(true);
                                            },
                                            child: Text(
                                              'この条件で検索する',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                          ),
                        ]
                      ),
                    )
                  );
                },
              );
            });
        },
      )
    );
  }
}



// ----インフィニティスクロール-------------
class GameArticleInfinityView extends StatefulWidget {
  // 記事一覧
  final List<GameArticleModel> articles;
  // ゲームを取得する関数
  final Future<dynamic> Function(bool) getContents;

  const GameArticleInfinityView({
    Key? key,
    required this.articles,
    required this.getContents,
  }) : super(key: key);

  @override
  State<GameArticleInfinityView> createState() => _GameArticleInfinityViewState();
}

class _GameArticleInfinityViewState extends State<GameArticleInfinityView> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  bool isPaging = true;

  /// 30文字以上の場合は、省略する
  String getArticleTitle(String title) {
    if (title.length >= 35) {
      title = "${title.substring(0, 35)}...";
    }
    return title;
  }



  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoading) {

        isPaging = SharedPrefe.getIsPaging();
        if (!isPaging) {
          setState (() {});
          return;
        }

        _isLoading = true;
        await widget.getContents(false);
        setState (() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.articles.length,
        // itemExtent: 150.0,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // _launchUrl(widget.articles[index].siteUrl);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext _context) => WebViewStack(
                    title: widget.articles[index].title,
                    url: widget.articles[index].siteUrl,
                  ),
                  // builder: (BuildContext _context) => WebViewScreen(
                  //   title: widget.articles[index].title,
                  //   url: widget.articles[index].siteUrl,
                  // ),
                ),
              );

            },
            child: Column(
              children: [
                index % 5 == 0 && index != 0
                ?
                // バナー広告
                AdModBanner(adModHight: 50.0)
                :
                const SizedBox(),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Image.network(
                            widget.articles[index].topImageUrl,
                            errorBuilder: (c, o, s) {
                              return const Icon(
                                Icons.downloading,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getArticleTitle(widget.articles[index].title),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                Text(
                                  widget.articles[index].siteName,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black45
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
                                Text(
                                  widget.articles[index].postDate,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.black45
                                  ),
                                ),
                              ],
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
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


