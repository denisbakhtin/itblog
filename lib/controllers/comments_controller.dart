import 'http/shelf.dart';

class CommentsController {
  static Future<Response> Index(Request request) async {
    return HtmlResponse.ok('["comment1"]');
  }

  static Future<Response> Details(Request request, String id) async {
    if (id == 'comment1') {
      return HtmlResponse.ok('user1');
    }
    return HtmlResponse.notFound();
  }
}
