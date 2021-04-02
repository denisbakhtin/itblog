import 'http/shelf.dart';

class TagsController {
  static Future<Response> Index(Request request) async {
    return HtmlResponse.ok('["tag1"]');
  }

  static Future<Response> Details(Request request, String id) async {
    if (id == 'tag1') {
      return HtmlResponse.ok('tag1');
    }
    return HtmlResponse.notFound();
  }
}
