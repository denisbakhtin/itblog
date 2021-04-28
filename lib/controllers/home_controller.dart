import 'package:itblog/views/views.dart';

import 'http/shelf.dart';

class HomeController {
//  final Database connection;
//  HomeController() : connection = Injector.appInstance.get<Database>();
//
//  Handler get handler {
//    final router = Router();
//
//    router.get('/', (Request request) async {
//      return HtmlResponse.ok('Home page design #2');
//    });
//
//    return router;
//  }
  static Future<Response> Index(Request request) async {
    return HtmlResponse.ok(HomeShowView(viewData: {'title': 'Home page'}));
  }
}
