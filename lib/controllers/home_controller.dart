import 'package:itblog/controllers/helpers.dart';
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
//      return Response.ok('Home page design #2');
//    });
//
//    return router;
//  }
  static Future<Response> Index(Request request) async {
    var vd = viewData(request);
    return Response.ok(HomeShowView(
        viewData: vd
          ..['hideSidebar'] = true
          ..['meta_description'] = ''));
  }
}
