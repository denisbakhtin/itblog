import 'data.dart';

class Mailing {
  int id;
  String createdAt;
  String title;
  String content;

  Mailing({
    this.id = 0,
    this.createdAt = '',
    this.title = '',
    this.content = '',
  });

  DateTime get created => DateTime.parse(createdAt);
  String get url => "/mailing/$id";
  static String get indexUrl => "/admin/mailings";
  static String get newUrl => "/admin/mailings/new";
  String get editUrl => "/admin/mailings/edit/$id";
  String get deleteUrl => "/admin/mailings/delete/$id";

  factory Mailing.fromMap(Map<String, dynamic> map) {
    return Mailing(
      id: toInt(map['id']),
      createdAt: toStr(map['created_at']),
      title: toStr(map['title']),
      content: toStr(map['content']),
    );
  }

  @override
  String toString() {
    return 'Mailing(id: $id, createdAt: $createdAt, title: $title, content: $content)';
  }
}
