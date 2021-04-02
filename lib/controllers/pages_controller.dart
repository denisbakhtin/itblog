import 'http/shelf.dart';

class PagesController {
  static Future<Response> Index(Request request) async {
    return HtmlResponse.ok('["page1"]');
  }

  static Future<Response> Details(Request request, String id) async {
    if (id == 'page1') {
      return HtmlResponse.ok('page1');
    }
    return HtmlResponse.notFound();
  }
}
