import 'data.dart';

class Page {
  int id;
  String title;
  String content;
  int published;
  String metaKeywords;
  String metaDescription;
  String slug;
  Page({
    this.id = 0,
    this.title = '',
    this.content = '',
    this.published = 0,
    this.metaKeywords = '',
    this.metaDescription = '',
    this.slug = '',
  }) {}

  String get url => "/pages/$id/$slug";
  static String get indexUrl => "/admin/pages";
  static String get newUrl => "/admin/pages/new";
  String get editUrl => "/admin/pages/edit/$id";
  String get deleteUrl => "/admin/pages/delete/$id";

  factory Page.fromMap(Map<String, dynamic> map) {
    return Page(
      id: toInt(map['id']),
      title: toStr(map['title']),
      content: toStr(map['content']),
      published: toInt(map['published']),
      metaKeywords: toStr(map['meta_keywords']),
      metaDescription: toStr(map['meta_description']),
      slug: toStr(map['slug']),
    );
  }

  @override
  String toString() {
    return 'Page(id: $id, title: $title, content: $content, published: $published, metaKeywords: $metaKeywords, metaDescription: $metaDescription, slug: $slug)';
  }
}
