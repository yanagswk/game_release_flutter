import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/models/notice.dart';
import 'package:http/http.dart' as http;

import 'package:release/models/game_info.dart';

class ApiClient {

  // final host = 'localhost';
  final host = 'yurubo0.com';

  /// ステータスコードチェック
  checkStatusCode(response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(response.body);
      throw Exception('${response.body}');
    }
  }

  /// 楽天apiから取得したゲーム情報を取得
  Future getGameInfo({
    required String hardware,
    required int limit,
    required int offset,
    required bool isReleased,
  }) async {
    print("api実行");
    print('limit: ${limit}, offset: ${offset}, hardware: ${hardware}, isReleased: ${isReleased}');

    final params = {
      'hardware': '$hardware',
      'limit': '$limit',
      'offset': '$offset',
      'is_released': '${isReleased ? 1 : 0}',
      'device_id' : SharedPrefe.getDeviceId(),
    };

    final uri = Uri.https(
      host,
      '/api/games/info',
      params
    );
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

    // GameInfoModel型に変換する
    // return gameInfo.map((e) {
    //   return GameInfoModel.fromMap(e);
    // }).toList();
    
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

    final uri = Uri.https(
      host,
      '/api/games/released',
      params
    );
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
    
    final uri = Uri.https(
      host,
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
    final uri = Uri.https(
      host,
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
      return GameInfoModel.fromMap(e);
    }).toList();
  }


  /// ゲームお気に入り登録
  Future<bool> addFavoriteGameApi(int gameId) async {
    final uri = Uri.https(
      host,
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
    final uri = Uri.https(
      host,
      '/api/games/remove/favorite',
      {
        'device_id' : SharedPrefe.getDeviceId(),
        'game_id'   : '$gameId',
      }
    );
    // api実行
    final response = await http.post(uri);

    print(gameId);

    final responseJson = checkStatusCode(response);

    return response.statusCode == 200 ? true : false;
  }


  /// ゲーム詳細取得
  Future getGameDetail(int gameId) async {
    final uri = Uri.https(
      host,
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
  Future sendContactForm(String message) async {
    final uri = Uri.https(
      host,
      '/api/contact/message',
      {
        'device_id' : SharedPrefe.getDeviceId(),
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


    /// ゲーム詳細取得
  Future getNoticeList() async {
    final uri = Uri.https(
      host,
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

}

