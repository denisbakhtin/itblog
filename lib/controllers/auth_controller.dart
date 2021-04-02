import 'package:itblog/models/database.dart';

import 'http/shelf.dart';

class AuthController {
  final Database connection;
  AuthController() : connection = Injector.appInstance.get<Database>();

  Handler get handler {
    final router = Router();

    router.get(r'/user', (Request request) async {
      return Response.ok('User');
    });
    router.add('POST', r'/login', (Request request) async {
      return Response.ok('Login successful');
    });
    router.add('POST', r'/register', (Request request) async {
      return Response.ok('Register successful');
    });
    router.all(
        r'/<ignored|.*>', (Request request) => Response.notFound('null'));

    return router;
  }
}
