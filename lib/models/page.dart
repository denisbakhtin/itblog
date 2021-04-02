class Page {
  int? id;
  String? title;
  String? content;
  bool? published;
  String? metaKeywords;
  String? metaDescription;
  String? slug;
  DateTime? createdAt;
  DateTime? updatedAt;
  Page({this.id, this.title, this.content, this.published, this.metaKeywords, this.metaDescription, this.slug, this.createdAt, this.updatedAt}) {}
}
