

class NoticeModel {

  /// お知らせタイトル
  final int id;

  /// お知らせタイトル
  final String title;

  /// お知らせ内容
  final String contents;

  /// 日付
  final String noticeDate;

  NoticeModel({
    required this.id,
    required this.title,
    required this.contents,
    required this.noticeDate,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map) {
    return NoticeModel(
      id: map['id'],
      title: map['title'],
      contents: map['contents'],
      noticeDate: map['created_at'],
    );
  }

}