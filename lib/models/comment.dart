
import 'post.dart';

class Comment {
  int? id;
  String? content;
  bool? published;
  String? slug;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? postId;
  Post? post;
  String? userName;
  Comment({this.id, this.content, this.published, this.slug, this.createdAt, this.updatedAt, this.postId, this.post, this.userName}) {}
}
