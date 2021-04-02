import 'comment.dart';
import 'tag.dart';

class Post {
  int? id;
  String? title;
  String? content;
  bool? published;
  String? metaKeywords;
  String? metaDescription;
  String? slug;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Tag>? tags;
  List<Comment>? comments;
  Post({this.id, this.title, this.content, this.published, this.metaKeywords, this.metaDescription, this.slug, this.createdAt, this.updatedAt, this.tags, this.comments}) {}
}
