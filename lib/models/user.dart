import 'post.dart';

class User {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? email;
  String? name;
  String? password;
  List<Post>? posts;
  User({this.id, this.createdAt, this.updatedAt, this.email, this.name, this.password, this.posts}) {}
}
