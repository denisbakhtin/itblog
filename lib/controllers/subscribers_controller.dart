import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'helpers.dart';
import 'http/shelf.dart';

class SubscribersController {
  Router get router {
    final router = Router();

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final subscriber = Subscriber.fromMap(form);
      db.createSubscriber(subscriber);
      return Response.movedPermanently("/");
    });

    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));
    return router;
  }
}

class AdminSubscribersController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final list = await db.subscribers();
      var vd = viewData(request);
      return Response.ok(SubscribersIndexView(list, viewData: vd));
    });

    router.get('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      try {
        var vd = viewData(request);
        final subscriber = await db.subscriber(toInt(id));
        return Response.ok(SubscribersFormView(subscriber, viewData: vd));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.post('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();

      final form = request.context['postParams'] as Map<String, dynamic>;
      final subscriber = Subscriber.fromMap(form);
      db.updateSubscriber(subscriber);
      return Response.movedPermanently(Subscriber.indexUrl);
    });

    router.post('/delete/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      await db.deleteSubscriber(toInt(id));
      return Response.movedPermanently(Subscriber.indexUrl);
    });

    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));
    return router;
  }
}
