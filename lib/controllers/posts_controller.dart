import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';

import 'helpers.dart';
import 'http/shelf.dart';

class PostsController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      try {
        //URI = scheme:[//authority]path[?query][#fragment]
        final uri = request.requestedUri;
        final page = uri.queryParameters['page'];
        var currentPage = toInt(page);
        currentPage = currentPage > 0 ? currentPage : 1;

        final posts = db.posts(published: 1, page: currentPage);
        final postsCount = db.postsCount(published: 1);
        var vd = viewData(request);

        final paginator = getPaginator(postsCount, currentPage: currentPage);
        final canonical =
            '${uri.scheme}://${uri.authority}${uri.path}${currentPage > 1 ? "?page=" + currentPage.toString() : ""}';
        if (paginator.length > 1) {
          if (paginator.first.title == "<<") {
            vd['prev'] = paginator.first.url;
          }
          if (paginator.last.title == ">>") {
            vd['next'] = paginator.last.url;
          }
        }

        return Response.ok(PostsPublicIndexView(
          posts,
          viewData: vd
            ..['title'] = 'Блог'
            ..['paginator'] = paginator
            ..['canonical'] = canonical,
        ));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.get('/<id>/<slug>', (Request request, String id, String slug) async {
      final db = Injector.appInstance.get<DB>();
      try {
        final post = await db.post(toInt(id), loadRelations: true);
        var vd = viewData(request);
        if (post.published == 0) {
          throw NotFoundException();
        }
        if (post.url != request.requestedUri.path) {
          return Response.movedPermanently(post.url);
        }
        return Response.ok(PostsShowView(
          post,
          viewData: vd
            ..['title'] = post.title
            ..['meta_description'] = post.metaDescription,
        ));
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

class AdminPostsController {
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final list = await db.posts();
      var vd = viewData(request);
      return Response.ok(PostsIndexView(list, viewData: vd));
    });

    router.get('/new', (Request request) async {
      var vd = viewData(request);
      return Response.ok(PostsFormView(Post(published: 1), viewData: vd));
    });

    router.post('/new', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      final form = request.context['postParams'] as Map<String, dynamic>;
      final post = Post.fromMap(form);
      db.createPost(post);
      return Response.movedPermanently(Post.indexUrl);
    });

    router.get('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      try {
        var vd = viewData(request);
        final post = await db.post(toInt(id), loadRelations: true);
        return Response.ok(PostsFormView(post, viewData: vd));
      } on NotFoundException {
        throw Error404();
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.post('/edit/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();

      final form = request.context['postParams'] as Map<String, dynamic>;
      final post = Post.fromMap(form);
      db.updatePost(post);
      return Response.movedPermanently(Post.indexUrl);
    });

    router.post('/delete/<id>', (Request request, String id) async {
      final db = Injector.appInstance.get<DB>();
      await db.deletePost(toInt(id));
      return Response.movedPermanently(Post.indexUrl);
    });

    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));
    return router;
  }
}
