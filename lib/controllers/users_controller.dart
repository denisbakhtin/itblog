import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'helpers.dart';
import 'http/shelf.dart';

class AdminUsersController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();

      var vd = viewData(request);
      final list = db.users();
      return Response.ok(UsersIndexView(list, viewData: vd));
    });

    router.get('/new', (Request request) async {
      var vd = viewData(request);
      return Response.ok(UsersFormView(User(), viewData: vd));
    });

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();

      final form = request.context['postParams'] as Map<String, dynamic>;
      final user = User.fromMap(form);
      db.createUser(user);
      return Response.movedPermanently("/admin/users");
    });

    router.get('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      try {
        final user = db.user(toInt(id));
        var vd = viewData(request);
        return Response.ok(UsersFormView(user, viewData: vd));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.post('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final user = User.fromMap(form);
      db.updateUser(user);
      return Response.movedPermanently("/admin/users");
    });

    router.post('/delete/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      await db.deleteUser(toInt(id));
      return Response.movedPermanently("/admin/users");
    });

    return router;
  }
}
