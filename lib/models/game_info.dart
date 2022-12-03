import 'package:intl/intl.dart';

/// ゲーム情報用のクラス
class GameInfoModel {
  /// ゲームid
  final int id;
  /// タイトル
  final String title;
  /// ハードウェア
  final String hardware;
  /// 値段
  final int price;
  /// 発売日
  final String salesDate;
  /// 画像URL
  final String largeImageUrl;
  /// 発売元
  final String label;
  /// 商品説明
  final String itemCaption;
  /// 商品URL
  final String itemUrl;
  /// レビュー件数
  final int reviewCount;
  /// レビュー平均
  final double reviewAverage;
  /// お気に入り済み
  bool isFavorite;


  // コンストラクター
  GameInfoModel({
    required this.id,
    required this.title,
    required this.hardware,
    required this.price,
    required this.salesDate,
    required this.largeImageUrl,
    required this.label,
    required this.itemCaption,
    required this.itemUrl,
    required this.reviewCount,
    required this.reviewAverage,
    required this.isFavorite
  });

  /// ゲーム一覧用 Map<String, dynamic>からGameInfoModelへ変換する
  factory GameInfoModel.fromMap(Map<String, dynamic> map) {
    // 日付フォーマット
    // final sales_date = map['sales_date'].replaceFirst('-', '年').replaceFirst('-', '月');

    return GameInfoModel(
      id: map['id'],
      title: map['title'],
      hardware: map['hardware'],
      price: map['price'],
      salesDate: map['sales_date'],
      largeImageUrl: map['large_image_url'],
      label: map['label'],
      itemCaption: map['item_caption'],
      itemUrl: map['item_url'],
      reviewCount: map['review_count'],
      reviewAverage: map['review_average'].toDouble(),  // int型からdouble型へ変換
      isFavorite: map['is_favorite']
    );
  }

  /// ゲーム詳細用 Map<String, dynamic>からGameInfoModelへ変換する
  factory GameInfoModel.detailFromMap(Map<String, dynamic> map) {
    // 日付フォーマット
    // final sales_date = map['sales_date'].replaceFirst('-', '年').replaceFirst('-', '月');

    return GameInfoModel(
      id: map['id'],
      title: map['title'],
      hardware: map['hardware'],
      price: map['price'],
      salesDate: map['sales_date'],
      largeImageUrl: map['large_image_url'],
      label: map['label'],
      itemCaption: map['item_caption'],
      itemUrl: map['item_url'],
      reviewCount: map['review_count'],
      reviewAverage: map['review_average'].toDouble(),  // int型からdouble型へ変換
      isFavorite: map['is_favorite']
    );
  }


  /// Map型に変換
  Map toJson() => {
    'id': id,
    'title': title,
    'hardware': hardware,
    'price': price,
    'salesDate': salesDate,
    'largeImageUrl': largeImageUrl,
    'label': label,
    'itemCaption': itemCaption,
    'itemUrl': itemUrl,
    'reviewCount': reviewCount,
    'reviewAverage': reviewAverage,
  };

  
}


// {
//   "GenreInformation": [],
//   "Items": [
//     {
//       "Item": {
//         "affiliateUrl": "",
//         "availability": "5",
//         "booksGenreId": "006514003001",
//         "discountPrice": 0,
//         "discountRate": 0,
//         "hardware": "Nintendo Switch",
//         "itemCaption": "
 
// 『ポケットモンスター』シリーズはオープンワールドへ。
// ポケモンを捕まえたり、交換したり、育ててバトルに挑んだり。『ポケットモンスター』シリーズならではの遊びを、"オープンワールド"の世界で楽しめます。
// 大自然や街には、至る所にポケモンたちが息づいており、境目なく広がるフィールドを自由に冒険することができます。
 
// 1、最初のパートナー
// あなたは、くさタイプの「ニャオハ」、ほのおタイプの「ホゲータ」、みずタイプの「クワッス」の3匹の中から1匹を選び冒険に出ることになります。はたして、どのように出会い、どのような物語を繰り広げるのでしょうか。
 
// 2、伝説のポケモン「ミライドン」
// 他のポケモンたちをはるかに凌駕する力を持つといわれていますが、その生態は謎に包まれています。「ミライドン」の背に乗ることで、陸を走ったり、水上を泳いだり、滑空したり、崖を登ったりすることができ、さらに冒険の幅が広がります。
 
// 3、「テラスタル」
// パルデア地方特有の現象で、この地で暮らすすべてのポケモンが「テラスタル」をすることができます。
// ポケモンごとにそれぞれ「テラスタイプ」を持っており、「テラスタル」することで、「テラスタイプ」に変化します。ほとんどのポケモンは、元のタイプと同じ「テラスタイプ」を持っていますが、中には元のタイプと異なるタイプを持つポケモンもいるようです。
// パルデア地方でのポケモンバトルでは、この「テラスタル」が、勝負のカギを握ります。
 
// 4、通信でつながる
// 本作は最大で4人同時のマルチプレイが可能。ポケモン交換や対戦などの通信プレイはもちろん、他のプレイヤーと同じフィールドを駆け巡りながら、一緒に冒険することもできます。
// また、野生のテラスタルしたポケモンに出会える「テラレイドバトル」にも他のプレイヤーと一緒に挑むことができます。
 
 
 
// &copy;2022 Pok&eacute;mon. &copy;1995-2022 Nintendo/Creatures Inc./GAME FREAK inc.
// 　ポケットモンスター・ポケモン・Pok&eacute;monは任天堂・クリーチャーズ・ゲームフリークの登録商標です。",
//         "itemPrice": 5670,
//         "itemUrl": "https://books.rakuten.co.jp/rb/17247720/",
//         "jan": "4902370550559",
//         "label": "任天堂",
//         "largeImageUrl": "https://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/0559/4902370550559.jpg?_ex=200x200",
//         "limitedFlag": 0,
//         "listPrice": 0,
//         "makerCode": "HAC-P-ALZYA",
//         "mediumImageUrl": "https://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/0559/4902370550559.jpg?_ex=120x120",
//         "postageFlag": 2,
//         "reviewAverage": "4.67",
//         "reviewCount": 15,
//         "salesDate": "2022年11月18日",
//         "smallImageUrl": "https://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/0559/4902370550559.jpg?_ex=64x64",
//         "title": "【特典+他】ポケットモンスター バイオレット(【早期購入外付特典】プロモカード「ピカチュウ」 ×1+『ポケットモンスター スカーレット・バイオレット』「予約 de ゲットキャンペーン」シリアルコード+他)",
//         "titleKana": "ポケットモンスター バイオレット"
//       }
//     },
//   ],
//   "carrier": 0,
//   "count": 5,
//   "first": 1,
//   "hits": 5,
//   "last": 5,
//   "page": 1,
//   "pageCount": 1
// }