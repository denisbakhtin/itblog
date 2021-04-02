import 'http/shelf.dart';

class UsersController {
  static Future<Response> Index(Request request) async {
    return HtmlResponse.ok('["user1"]');
  }

  static Future<Response> Details(Request request, String id) async {
    if (id == 'user1') {
      return HtmlResponse.ok('user1');
    }
    return HtmlResponse.notFound();
  }
}
