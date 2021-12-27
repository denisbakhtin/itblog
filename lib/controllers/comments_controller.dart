import 'package:itblog/controllers/helpers.dart';
import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'http/shelf.dart';

class CommentsController {
  Router get router {
    final router = Router();

    router.get('/form/<postId>', (Request request, String postId) async {
      return Response.ok(
          PartialCommentsPublicFormView(Comment(postId: toInt(postId))));
    });

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final comment = Comment.fromMap(form)..published = 0;
      db.createComment(comment);
      setMessage(request, 'Ваш комментарий будет опубликован после проверки.');
      return Response.movedPermanently(
          Post(id: comment.postId, slug: 'abc').url);
    });

    return router;
  }
}

class AdminCommentsController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final list = db.comments();
      var vd = viewData(request);
      return Response.ok(CommentsIndexView(list, viewData: vd));
    });

    router.get('/new', (Request request) async {
      var vd = viewData(request);
      return Response.ok(CommentsFormView(Comment(), viewData: vd));
    });

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final comment = Comment.fromMap(form);
      db.createComment(comment);
      return Response.movedPermanently("/admin/comments");
    });

    router.get('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      try {
        final comment = db.comment(toInt(id), loadRelations: true);
        var vd = viewData(request);
        return Response.ok(CommentsFormView(comment, viewData: vd));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.post('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final comment = Comment.fromMap(form);
      db.updateComment(comment);
      return Response.movedPermanently("/admin/comments");
    });

    router.post('/delete/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      db.deleteComment(toInt(id));
      return Response.movedPermanently("/admin/comments");
    });

    return router;
  }
}
