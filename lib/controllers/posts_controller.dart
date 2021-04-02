import 'http/shelf.dart';

class PostsController {
  static Future<Response> Index(Request request) async {
    return HtmlResponse.ok('["post1"]');
  }

  static Future<Response> Details(Request request, String id) async {
    if (id == 'post1') {
      return HtmlResponse.ok('user1');
    }
    return HtmlResponse.notFound();
  }
}
