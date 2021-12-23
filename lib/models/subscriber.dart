import 'data.dart';

class Subscriber {
  int id;
  String email;
  String createdAt;
  Subscriber({
    this.id = 0,
    this.email = '',
    this.createdAt = '',
  });

  DateTime get created => DateTime.parse(createdAt);
  static String get indexUrl => "/admin/subscribers";
  static String get newUrl => "/admin/subscribers/new";
  String get editUrl => "/admin/subscribers/edit/$id";
  String get deleteUrl => "/admin/subscribers/delete/$id";

  factory Subscriber.fromMap(Map<String, dynamic> map) {
    return Subscriber(
      id: toInt(map['id']),
      email: toStr(map['email']),
      createdAt: toStr(map['created_at']),
    );
  }

  @override
  String toString() {
    return 'Subscriber(id: $id, email: $email, createdAt: $createdAt)';
  }
}
