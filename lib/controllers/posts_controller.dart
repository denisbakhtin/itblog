import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'http/shelf.dart';

class PostsController {
  static Future<Response> PublicIndex(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final posts = await db.posts(published: 1);
      return HtmlResponse.ok(PostsIndexView(posts));
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> Index(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final posts = await db.posts();
      return HtmlResponse.ok(PostsIndexView(posts));
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> Details(
      Request request, String id, String slug) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final post = await db.post(toInt(id));
      //TODO: check canonical url, published state and so on
      return HtmlResponse.ok(PostsShowView(post));
    } on NotFoundException {
      return HtmlResponse.notFound();
    } catch (e) {
      return HtmlResponse.internalServerError();
    }
  }

  static Future<Response> New(Request request) async {
    return HtmlResponse.ok(PostsFormView(Post()));
  }

  static Future<Response> Create(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final post = Post.fromMap(form);
      db.createPost(post);
      return HtmlResponse.movedPermanently("/admin/posts");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Edit(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final post = await db.post(toInt(id));
      return HtmlResponse.ok(PostsFormView(post));
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
      final post = Post.fromMap(form);
      db.updatePost(post);
      return HtmlResponse.movedPermanently("/admin/posts");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Delete(Request request, String id) async {
    final db = Injector.appInstance.get<DB>();
    try {
      await db.deletePost(toInt(id));
      return HtmlResponse.movedPermanently("/admin/posts");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }
}
