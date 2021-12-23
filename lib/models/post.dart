import 'data.dart';
import 'package:html/parser.dart';

class Post {
  int id;
  String title;
  String content;
  int published;
  String metaKeywords;
  String metaDescription;
  String slug;
  String createdAt;
  List<Tag>? tags;
  List<Comment>? comments;
  Post(
      {this.id = 0,
      this.title = '',
      this.content = '',
      this.published = 0,
      this.metaKeywords = '',
      this.metaDescription = '',
      this.slug = '',
      this.createdAt = '',
      this.tags = const [],
      this.comments = const []});

  DateTime get created => DateTime.parse(createdAt);
  String get url => "/posts/$id/$slug";
  static String get indexUrl => "/admin/posts";
  static String get pubIndexUrl => "/posts";
  static String get newUrl => "/admin/posts/new";
  String get editUrl => "/admin/posts/edit/$id";
  String get deleteUrl => "/admin/posts/delete/$id";

  String get excerpt {
    const limit = 150;
    final plainText =
        parse(parse(content).body?.text).documentElement?.text ?? '';
    return plainText.length > limit
        ? plainText.substring(0, limit) + '...'
        : plainText;
  }

  List<Breadcrumb> get breadcrumbs => [];

  String getImage() {
    var reg = RegExp(r'<img[^<>]+src="([^"]+)"[^<>]*>');
    return reg.firstMatch(content)?.group(1) ?? '';
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: toInt(map['id']),
      title: toStr(map['title']),
      content: toStr(map['content']),
      published: toInt(map['published']),
      metaKeywords: toStr(map['meta_keywords']),
      metaDescription: toStr(map['meta_description']),
      slug: toStr(map['slug']),
      createdAt: toStr(map['created_at']),
      tags: map['tags[]'] != null
          ? (map['tags[]'] as List<dynamic>)
              .map((e) => (e is String)
                  ? Tag(title: e)
                  : Tag.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
      comments: map['comments'] != null
          ? (map['comments'] as List<dynamic>)
              .map((e) => Comment.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, content: $content, published: $published, metaKeywords: $metaKeywords, metaDescription: $metaDescription, slug: $slug)';
  }
}
