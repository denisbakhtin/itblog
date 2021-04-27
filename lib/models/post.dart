import 'data.dart';

class Post {
  int id;
  String title;
  String content;
  int published;
  String metaKeywords;
  String metaDescription;
  String slug;
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
      this.tags = const [],
      this.comments = const []});

  String get url => "/posts/$id-$slug";
  static String get newUrl => "/admin/new_post";
  String get editUrl => "/admin/edit_post/$id";
  String get deleteUrl => "/admin/delete_post/$id";

  String get excerpt => "";
  List<Breadcrumb> get breadcrumbs => [];

  String getImage() {
    return '';
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
      tags: map['tags'] != null
          ? (map['tags'] as List<dynamic>)
              .map((e) => Tag.fromMap(e as Map<String, dynamic>))
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
