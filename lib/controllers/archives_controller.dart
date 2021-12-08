import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'helpers.dart';
import 'http/shelf.dart';

class ArchivesController {
  Router get router {
    final router = Router();

    router.get('/<year>-<month>',
        (Request request, String year, String month) async {
      final db = Injector.appInstance.get<DB>();
      try {
        final posts = await db.archive(year, month);
        var vd = viewData(request);
        return Response.ok(ArchivesShowView(posts,
            viewData: vd
              ..['title'] =
                  'Записи за ${monthName(toInt(month)).toLowerCase()} ${year}'));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));
    return router;
  }
}
