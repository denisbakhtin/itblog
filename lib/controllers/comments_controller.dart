import 'http/shelf.dart';

class CommentsController {
  static Future<Response> Index(Request request) async {
    return HtmlResponse.ok('["comment1"]');
  }

  static Future<Response> Details(Request request, int id) async {
    if (id == 'comment1') {
      return HtmlResponse.ok('user1');
    }
    return HtmlResponse.notFound();
  }

  static Future<Response> Create(Request request, int postId) async {
    return HtmlResponse.notFound();
  }

  static Future<Response> Edit(Request request, int id) async {
    return HtmlResponse.notFound();
  }

  static Future<Response> Update(Request request, int id) async {
    return HtmlResponse.notFound();
  }

  static Future<Response> Delete(Request request, int id) async {
    return HtmlResponse.notFound();
  }
}
