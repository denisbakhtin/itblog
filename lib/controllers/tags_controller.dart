import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'helpers.dart';
import 'http/shelf.dart';

class TagsController {
  Router get router {
    final router = Router();

    router.get('/<slug>', (Request request, String slug) async {
      final db = Injector.appInstance.get<DB>();
      try {
        final tag = db.tagBySlug(slug, loadRelations: true);
        var vd = viewData(request);
        if (tag.url != request.requestedUri.path) {
          return Response.seeOther(tag.url);
        }
        return Response.ok(TagsShowView(tag,
            viewData: vd..['title'] = 'Записи с тэгом #${tag.title}'));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    return router;
  }
}

class AdminTagsController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final list = await db.tags();
      var vd = viewData(request);
      return Response.ok(TagsIndexView(list, viewData: vd));
    });

    router.get('/new', (Request request) async {
      var vd = viewData(request);
      return Response.ok(TagsFormView(Tag(), viewData: vd));
    });

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final tag = Tag.fromMap(form);
      db.createTag(tag);
      return Response.movedPermanently("/admin/tags/");
    });

    router.get('/edit/<id>', (Request request) async {
      var vd = viewData(request);
      return Response.ok(TagsFormView(Tag(), viewData: vd));
    });

    router.post('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final tag = Tag.fromMap(form);
      db.updateTag(tag);
      return Response.movedPermanently("/admin/tags/");
    });

    router.post('/delete/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();

      await db.deleteTag(toInt(id));
      return Response.movedPermanently("/admin/tags/");
    });

    return router;
  }
}
