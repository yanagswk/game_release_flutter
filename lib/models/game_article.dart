/// ゲーム情報用のクラス
class GameArticleModel {
  /// 記事id
  final int id;
  /// 記事のサイトid
  final int siteId;
  /// 記事のサイト名
  final String siteName;
  /// 記事のurl
  final String siteUrl;
  /// 記事のタイトル
  final String title;
  /// ジャンル
  final String genre;
  /// 記事のトップ画像
  final String topImageUrl;
  /// 記事の投稿日時
  final String postDate;

  // コンストラクター
  GameArticleModel({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.siteUrl,
    required this.title,
    required this.genre,
    required this.topImageUrl,
    required this.postDate,
  });

  factory GameArticleModel.fromMap(Map<String, dynamic> map) {
    return GameArticleModel(
      id: map['id'],
      siteId: map['site_id'],
      siteName: map['site_name'],
      // siteUrl: Uri.parse(map['site_url']),
      siteUrl: map['site_url'],
      title: map['title'],
      genre: map['genre'],
      topImageUrl: map['top_image_url'],
      postDate: map['post_date'],
    );
  }
}
