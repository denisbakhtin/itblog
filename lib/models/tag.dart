import 'post.dart';

class Tag {
  int? id;
  String? title;
  String? content;
  bool? published;
  String? metaKeywords;
  String? metaDescription;
  String? slug;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Post>? posts;
  Tag({this.id, this.title, this.content, this.published, this.metaKeywords, this.metaDescription, this.slug, this.createdAt, this.updatedAt, this.posts}) {}
}
