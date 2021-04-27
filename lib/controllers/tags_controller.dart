import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'http/shelf.dart';

class TagsController {
  static Future<Response> PublicIndex(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final tags = await db.tags(published: 1);
      return HtmlResponse.ok(TagsIndexView(tags));
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> Index(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final tags = await db.tags();
      return HtmlResponse.ok(TagsIndexView(tags));
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> Details(Request request, String slug) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final tag = await db.tagBySlug(slug);
      //TODO: check canonical url, published state and so on
      return HtmlResponse.ok(TagsShowView(tag));
    } on NotFoundException {
      return HtmlResponse.notFound();
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> New(Request request) async {
    return HtmlResponse.ok(TagsFormView(Tag()));
  }

  static Future<Response> Create(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final tag = Tag.fromMap(form);
      db.createTag(tag);
      return HtmlResponse.movedPermanently("/admin/tags");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Edit(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final tag = await db.tag(toInt(id));
      return HtmlResponse.ok(TagsFormView(tag));
    } on NotFoundException {
      return HtmlResponse.notFound();
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Update(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final tag = Tag.fromMap(form);
      db.updateTag(tag);
      return HtmlResponse.movedPermanently("/admin/tags");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Delete(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      await db.deleteTag(toInt(id));
      return HtmlResponse.movedPermanently("/admin/tags");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }
}
