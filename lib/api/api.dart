import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/models/game_article.dart';
import 'package:release/models/notice.dart';
import 'package:http/http.dart' as http;

import 'package:release/models/game_info.dart';
import 'package:release/models/notification.dart';

class ApiClient {

  // final host = 'localhost';
  // final host = 'yurubo0.com';

  /// ステータスコードチェック
  checkStatusCode(response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(response.body);
      throw Exception('${response.body}');
    }
  }


  /// uri作成
  Uri createUri(String url, Map<String, String> params) {
    return Uri.https(
      "yurubo0.com",
      url,
      params
    );
    // return Uri.http(
    //   "localhost",
    //   url,
    //   params
    // );
  }

  /// 楽天apiから取得したゲーム情報を取得
  Future getGameInfo({
    required String hardware,
    required int limit,
    required int offset,
    required int isReleased,
    int? releasedYear,
    int? releasedMonth,
  }) async {
    print("ゲーム一覧取得api実行");
    print(
      'limit: ${limit},offset: ${offset}, hardware: ${hardware}, isReleased: ${isReleased}, releasedYear: ${releasedYear}, releasedMonth: ${releasedMonth}'
    );

    final params = {
      'hardware': '$hardware',
      'limit': '$limit',
      'offset': '$offset',
      'is_released': '${isReleased}',
      'device_id' : SharedPrefe.getDeviceId(),
      'releasedYear': '${releasedYear}',
      'releasedMonth': '${releasedMonth}',
    };

    // final uri = Uri.https(
    //   host,
    //   '/api/games/info',
    //   params
    // );
    final uri = createUri('/api/games/info', params);
    // api実行
    final response = await http.get(uri);
    final responseJson = checkStatusCode(response);

    final List gameInfo = responseJson['games'];

    final gameModel = gameInfo.map((e) {
      return GameInfoModel.fromMap(e);
    }).toList();


    return {
      'game_count': responseJson['game_count'],
      'game': gameModel
    };
  }


  /// ゲーム検索
  Future getSearchGames({
    required String hardware,
    required String searchWord,
    required int limit,
    required int offset,
    int? year,
    String? month,
    String? sort
  }) async {
    print("検索api実行");
    print(
      'limit: ${limit},offset: ${offset}, hardware: ${hardware}, search_year: ${year}, search_month: ${month}, search_word: ${searchWord}'
    );

    final params = {
      'hardware': '$hardware',
      'search_word': '$searchWord',
      'limit': '$limit',
      'offset': '$offset',
      'device_id' : SharedPrefe.getDeviceId(),
      'search_year': '$year',
      'search_month': '$month',
      'sort': '$sort',
    };

    // final uri = Uri.https(
    //   host,
    //   '/api/games/info',
    //   params
    // );
    final uri = createUri('/api/games/info', params);
    // api実行
    final response = await http.get(uri);
    final responseJson = checkStatusCode(response);

    final List gameInfo = responseJson['games'];

    final gameModel = gameInfo.map((e) {
      return GameInfoModel.fromMap(e);
    }).toList();

    return {
      'game_count': responseJson['game_count'],
      'game': gameModel
    };
  }

  /// ゲーム検索
  Future getSearchWordGames({
    required String hardware,
    required String searchWord,
    required int limit,
    required int offset,
    String? sort
  }) async {
    print("検索api実行");
    print(
      'limit: ${limit},offset: ${offset}, hardware: ${hardware}, search_word: ${searchWord}'
    );

    final params = {
      'hardware': '$hardware',
      'search_word': '$searchWord',
      'limit': '$limit',
      'offset': '$offset',
      'device_id' : SharedPrefe.getDeviceId(),
      'sort': '$sort',
    };

    // final uri = Uri.https(
    //   host,
    //   '/api/games/info',
    //   params
    // );
    final uri = createUri('/api/games/info', params);
    // api実行
    final response = await http.get(uri);
    final responseJson = checkStatusCode(response);

    final List gameInfo = responseJson['games'];

    final gameModel = gameInfo.map((e) {
      return GameInfoModel.fromMap(e);
    }).toList();

    return {
      'game_count': responseJson['game_count'],
      'game': gameModel
    };
  }

  /// ゲーム検索
  Future getGenreGames({
    required String hardware,
    required String genre,
    required int isReleased,
    required int limit,
    required int offset,
    String? sort
  }) async {
    print("検索api実行");
    print(
      'limit: ${limit},offset: ${offset}, hardware: ${hardware}, genre: ${genre}, isReleased :${isReleased}, sort :${sort}'
    );

    final params = {
      'hardware': '$hardware',
      'genre': '$genre',
      'is_released': '$isReleased',
      'limit': '$limit',
      'offset': '$offset',
      'device_id' : SharedPrefe.getDeviceId(),
      'sort': '$sort',
    };

    // final uri = Uri.https(
    //   host,
    //   '/api/games/info',
    //   params
    // );
    final uri = createUri('/api/games/info', params);
    // api実行
    final response = await http.get(uri);
    final responseJson = checkStatusCode(response);

    final List gameInfo = responseJson['games'];

    final gameModel = gameInfo.map((e) {
      return GameInfoModel.fromMap(e);
    }).toList();

    return {
      'game_count': responseJson['game_count'],
      'game': gameModel
    };
  }

  /// 楽天apiから取得したゲーム情報を取得
  Future<List<GameInfoModel>> getReleasedGameInfo({
    // ゲームタイトル
    String? title = '',
    // ハードウェア
    String? hardware = '',
    // ソート
    String? sort = '',
    // ページ
    int page = 1,
  }) async {

    final params = {
      'hardware': '$hardware',
      'limit': '30',
      'offset': '0',
    };

    // final uri = Uri.https(
    //   host,
    //   '/api/games/released',
    //   params
    // );
    final uri = createUri('/api/games/released', params);
    // api実行
    final response = await http.get(uri);
    // json型に変換
    final responseJson = checkStatusCode(response);
    final List gameInfo = responseJson['games'];

    // GameInfoModel型に変換する
    return gameInfo.map((e) {
      return GameInfoModel.fromMap(e);
    }).toList();
  }


  /// デバイス情報登録
  Future registerDeviceInfo(String deviceId) async {
    // final uri = Uri.https(
    //   host,
    //   '/api/register/device',
    //   {
    //     'device_id': '$deviceId',
    //   }
    // );
    final uri = createUri(
      '/api/register/device',
      {
        'device_id': '$deviceId',
      }
    );
    // api実行
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      SharedPrefe.setDeviceId(deviceId);
      return true;
    } else {
      return false;
    }
  }


  /// お気に入りゲーム一覧取得
  Future getFavoriteGameList() async {
    // final uri = Uri.https(
    //   host,
    //   '/api/games/favorite',
    //   {
    //     'device_id': SharedPrefe.getDeviceId(),
    //   }
    // );
    print("お気に入りapi実行");
    final uri = createUri(
      '/api/games/favorite',
      {
        'device_id': SharedPrefe.getDeviceId(),
      }
    );
    // api実行
    final response = await http.get(uri);
    // json型に変換
    final responseJson = checkStatusCode(response);
    final List gameInfo = responseJson['data'];

    // GameInfoModel型に変換する
    return gameInfo.map((e) {
      // return GameInfoModel.fromMap(e);
      return GameInfoModel.favoriteMap(e);
    }).toList();
  }


  /// ゲームお気に入り登録
  Future<bool> addFavoriteGameApi(int gameId) async {
    // final uri = Uri.https(
    //   host,
    //   '/api/games/add/favorite',
    //   {
    //     'device_id' : SharedPrefe.getDeviceId(),
    //     'game_id'   : '$gameId',
    //   }
    // );
    final uri = createUri(
      '/api/games/add/favorite',
      {
        'device_id' : SharedPrefe.getDeviceId(),
        'game_id'   : '$gameId',
      }
    );
    // api実行
    final response = await http.post(uri);
    final responseJson = checkStatusCode(response);

    return response.statusCode == 200 ? true : false;
  }


  /// ゲームお気に入り解除
  Future<bool> removeFavoriteGameApi(int gameId) async {
    // final uri = Uri.https(
    //   host,
    //   '/api/games/remove/favorite',
    //   {
    //     'device_id' : SharedPrefe.getDeviceId(),
    //     'game_id'   : '$gameId',
    //   }
    // );
    final uri = createUri(
      '/api/games/remove/favorite',
      {
        'device_id' : SharedPrefe.getDeviceId(),
        'game_id'   : '$gameId',
      }
    );
    // api実行
    final response = await http.post(uri);

    final responseJson = checkStatusCode(response);

    return response.statusCode == 200 ? true : false;
  }


  /// ゲーム詳細取得
  Future getGameDetail(int gameId) async {
    // final uri = Uri.https(
    //   host,
    //   '/api/games/detail',
    //   {
    //     'device_id' : SharedPrefe.getDeviceId(),
    //     'game_id'   : '$gameId',
    //   }
    // );
    final uri = createUri(
      '/api/games/detail',
      {
        'device_id' : SharedPrefe.getDeviceId(),
        'game_id'   : '$gameId',
      }
    );
    // api実行
    final response = await http.get(uri);

    // json型に変換
    final responseJson = checkStatusCode(response);
    final Map<String, dynamic> gameInfo = responseJson['data'];

    // GameInfoModel型に変換する
    return GameInfoModel.detailFromMap(gameInfo);
  }

    /// お問い合せ送信
  Future sendContactForm(
    String nickname,
    String email,
    String message,
  ) async {
    // final uri = Uri.https(
    //   host,
    //   '/api/contact/message',
    //   {
    //     'device_id' : SharedPrefe.getDeviceId(),
    //     'nickname'  : '$nickname',
    //     'email'     : '$email',
    //     'message'   : '$message',
    //   }
    // );
    final uri = createUri(
      '/api/contact/message',
      {
        'device_id' : SharedPrefe.getDeviceId(),
        'nickname'  : '$nickname',
        'email'     : '$email',
        'message'   : '$message',
      }
    );
    // api実行
    final response = await http.post(uri);
    // json型に変換
    final responseJson = checkStatusCode(response);
    // GameInfoModel型に変換する
    return response.statusCode == 200 ? true : false;
  }


  /// ゲームお知らせ取得
  Future getNoticeList() async {
    // final uri = Uri.https(
    //   host,
    //   '/api/notice',
    //   {
    //     'device_id' : SharedPrefe.getDeviceId(),
    //   }
    // );
    final uri = createUri(
      '/api/notice',
      {
        'device_id' : SharedPrefe.getDeviceId(),
      }
    );
    // api実行
    final response = await http.get(uri);

    // json型に変換
    final responseJson = checkStatusCode(response);
    final List noticeList = responseJson['data'];

    return noticeList.map((e) {
      return NoticeModel.fromMap(e);
    }).toList();
  }


  /// 通知登録
  Future notificationRegister (int gameId) async {
    // final uri = Uri.https(
    //   host,
    //   '/api/notification/register',
    //   {
    //     'device_id' : SharedPrefe.getDeviceId(),
    //     'game_id'   : '$gameId',
    //   }
    // );
    final uri = createUri(
      '/api/notification/register',
      {
        'device_id' : SharedPrefe.getDeviceId(),
        'game_id'   : '$gameId',
      }
    );
    // api実行
    final response = await http.post(uri);
    // json型に変換
    final responseJson = checkStatusCode(response);
    // // GameInfoModel型に変換する
    // return response.statusCode == 200 ? true : false;
    final notification = responseJson['data'];

    return NotificationModel.fromMap(notification);
  }


  /// 通知キャンセル
  Future notificationCancel (int gameId, int notificationId) async {
    // final uri = Uri.https(
    //   host,
    //   '/api/notification/cancel',
    //   {
    //     'device_id'         : SharedPrefe.getDeviceId(),
    //     'game_id'           : '$gameId',
    //     'notification_id'   : '$notificationId',
    //   }
    // );
    final uri = createUri(
      '/api/notification/cancel',
      {
        'device_id'         : SharedPrefe.getDeviceId(),
        'game_id'           : '$gameId',
        'notification_id'   : '$notificationId',
      }
    );
    // api実行
    final response = await http.post(uri);
    return response.statusCode == 200 ? true : false;
  }


    /// ゲーム記事一覧取得
  Future getGameArticle({
    required String postType,
    required int offset,
    required int limit,
    String? postDate,
    int? siteId,
  }) async {
    print("ゲーム記事取得api実行");
    final test = siteId ?? '';

    var date = "";
    if (postType == "target") {
      date = postDate!;
    }

    print(
      'limit: ${limit},offset: ${offset}, postType: ${postType}, date :${date}, test: ${test}'
    );

    final params = {
      'device_id' : SharedPrefe.getDeviceId(),
      'post_type' : "${postType}",
      'offset' : "${offset}",
      'limit' : "${limit}",
      'post_date' : "${date}",
      'site_id'    : "${test}"
    };
    // final uri = Uri.https(
    //   host,
    //   '/api/article/index',
    //   params
    // );
    final uri = createUri(
      '/api/article/index',
      params
    );
    // api実行
    final response = await http.get(uri);
    final responseJson = checkStatusCode(response);

    final List gameArticle = responseJson['game_article'];

    final articleModel = gameArticle.map((e) {
      return GameArticleModel.fromMap(e);
    }).toList();

    return {
      'article_count': responseJson['article_count'],
      'article': articleModel
    };


  }

}