import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'http/shelf.dart';

class PagesController {
  static Future<Response> Index(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final pages = db.pages();
      return HtmlResponse.ok(PagesIndexView(pages));
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> Details(
      Request request, String id, String slug) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final page = db.page(toInt(id));
      //TODO: check canonical url, published state and so on
      return HtmlResponse.ok(PagesShowView(page));
    } on NotFoundException {
      return HtmlResponse.notFound();
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> New(Request request) async {
    return HtmlResponse.ok(PagesFormView(Page()));
  }

  static Future<Response> Create(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final page = Page.fromMap(form);
      db.createPage(page);
      return HtmlResponse.movedPermanently("/admin/pages");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Edit(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final page = db.page(toInt(id));
      return HtmlResponse.ok(PagesFormView(page));
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
      final page = Page.fromMap(form);
      db.updatePage(page);
      return HtmlResponse.movedPermanently("/admin/pages");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Delete(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      db.deletePage(toInt(id));
      return HtmlResponse.movedPermanently("/admin/pages");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }
}
