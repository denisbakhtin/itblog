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

  String get url => "/pages/$id-$slug";
  static String get newUrl => "/admin/new_page";
  String get editUrl => "/admin/edit_page/$id";
  String get deleteUrl => "/admin/delete_page/$id";

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
