import 'data.dart';

class Tag {
  int id;
  String title;
  String content;
  int published;
  String metaKeywords;
  String metaDescription;
  String slug;
  List<Post> posts;
  Tag(
      {this.id = 0,
      this.title = '',
      this.content = '',
      this.published = 0,
      this.metaKeywords = '',
      this.metaDescription = '',
      this.slug = '',
      this.posts = const []});

  String get url => "/tags/$slug";
  static String get indexUrl => "/admin/tags";
  static String get newUrl => "/admin/tags/new";
  String get editUrl => "/admin/tags/edit/$id";
  String get deleteUrl => "/admin/tags/delete/$id";

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: toInt(map['id']),
      title: toStr(map['title']),
      content: toStr(map['content']),
      published: toInt(map['published']),
      metaKeywords: toStr(map['meta_keywords']),
      metaDescription: toStr(map['meta_description']),
      slug: toStr(map['slug']),
      posts: map['posts'] != null
          ? (map['posts'] as List<dynamic>)
              .map((e) => Post.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  @override
  String toString() {
    return 'Tag(id: $id, title: $title, content: $content, published: $published, metaKeywords: $metaKeywords, metaDescription: $metaDescription, slug: $slug)';
  }
}
