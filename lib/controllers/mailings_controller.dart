import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'helpers.dart';
import 'http/shelf.dart';

class AdminMailingsController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final list = await db.mailings();
      var vd = viewData(request);
      return Response.ok(MailingsIndexView(list, viewData: vd));
    });

    router.get('/new', (Request request) async {
      var vd = viewData(request);
      return Response.ok(MailingsFormView(Mailing(), viewData: vd));
    });

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final mailing = Mailing.fromMap(form);
      db.createMailing(mailing);
      return Response.movedPermanently(Mailing.indexUrl);
    });

    router.get('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      try {
        var vd = viewData(request);
        final mailing = await db.mailing(toInt(id));
        return Response.ok(MailingsFormView(mailing, viewData: vd));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.post('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();

      final form = request.context['postParams'] as Map<String, dynamic>;
      final mailing = Mailing.fromMap(form);
      db.updateMailing(mailing);
      return Response.movedPermanently(Mailing.indexUrl);
    });

    router.post('/delete/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      await db.deleteMailing(toInt(id));
      return Response.movedPermanently(Mailing.indexUrl);
    });

    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));
    return router;
  }
}
