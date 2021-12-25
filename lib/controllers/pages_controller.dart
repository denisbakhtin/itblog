import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'helpers.dart';
import 'http/shelf.dart';

class PagesController {
  Router get router {
    final router = Router();

    router.get('/<id>/<slug>', (Request request, String id, String slug) async {
      final db = Injector.appInstance.get<DB>();
      try {
        final page = db.page(toInt(id));
        var vd = viewData(request);
        if (page.published == 0 || page.url != request.requestedUri.path) {
          throw NotFoundException();
        }
        return Response.ok(PagesShowView(page,
            viewData: vd
              ..['title'] = page.title
              ..['meta_description'] = page.metaDescription));
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

class AdminPagesController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();

      var vd = viewData(request);
      final list = db.pages();
      return Response.ok(PagesIndexView(list, viewData: vd));
    });

    router.get('/new', (Request request) async {
      var vd = viewData(request);
      return Response.ok(PagesFormView(Page(), viewData: vd));
    });

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();

      final form = request.context['postParams'] as Map<String, dynamic>;
      final page = Page.fromMap(form);
      db.createPage(page);
      buildSitemapXML();
      return Response.movedPermanently(Page.indexUrl);
    });

    router.get('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      try {
        var vd = viewData(request);
        final page = db.page(toInt(id));
        return Response.ok(PagesFormView(page, viewData: vd));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.post('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final page = Page.fromMap(form);
      db.updatePage(page);
      buildSitemapXML();
      return Response.movedPermanently(Page.indexUrl);
    });

    router.post('/delete/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      db.deletePage(toInt(id));
      buildSitemapXML();
      return Response.movedPermanently(Page.indexUrl);
    });

    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));
    return router;
  }
}
