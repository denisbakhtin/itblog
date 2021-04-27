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
  String get newUrl => "/admin/new_tag";
  String get editUrl => "/admin/edit_tag/$id";
  String get deleteUrl => "/admin/delete_tag/$id";

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
