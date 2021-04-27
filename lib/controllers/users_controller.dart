import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'http/shelf.dart';

class UsersController {
  static Future<Response> Index(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final users = db.users();
      return HtmlResponse.ok(UsersIndexView(users));
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> New(Request request) async {
    return HtmlResponse.ok(UsersFormView(User()));
  }

  static Future<Response> Create(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final user = User.fromMap(form);
      db.createUser(user);
      return HtmlResponse.movedPermanently("/admin/users");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Edit(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final user = db.user(toInt(id));
      return HtmlResponse.ok(UsersFormView(user));
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
      final user = User.fromMap(form);
      db.updateUser(user);
      return HtmlResponse.movedPermanently("/admin/users");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Delete(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      await db.deleteUser(toInt(id));
      return HtmlResponse.movedPermanently("/admin/users");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }
}
