import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';
import 'package:shelf_static/shelf_static.dart';

import 'auth_controller.dart';
import 'comments_controller.dart';
import 'home_controller.dart';
import 'http/auth_middleware.dart';
import 'http/shelf.dart';
import 'pages_controller.dart';
import 'posts_controller.dart';
import 'tags_controller.dart';
import 'users_controller.dart';

class BlogRouter {
  Handler get handler {
    final router = Router();

    //serve all static files under /public/ url. Consider using cascade router with static files coming first, web urls next
    router.mount('/public/',
        createStaticHandler('lib/public', defaultDocument: 'robots.txt'));

    //Can't group actions in controllers atm because of this https://github.com/google/dart-neats/issues/67
    //so have to attach actions directly
//    router.mount('/', HomeController().handler);
    router.get('/', HomeController.Index);

    router.get(r'/admin/pages', PagesController.Index);
    router.get(r'/pages/<id>/<slug>', PagesController.Details);
    router.get(r'/admin/new_page', PagesController.New);
    router.post(r'/admin/new_page', PagesController.Create);
    router.get(r'/admin/edit_page/<id>', PagesController.Edit);
    router.post(r'/admin/edit_page/<id>', PagesController.Update);
    router.post(r'/admin/delete_page/<id>', PagesController.Delete);

    router.get(r'/signin', AuthController.Signin);
    router.post(r'/signin', AuthController.DoSignin);
    router.get(r'/signup', AuthController.Signup);
    router.post(r'/signup', AuthController.DoSignup);

    router.get(r'/posts', PostsController.PublicIndex);
    router.get(r'/admin/posts', PostsController.Index);
    router.get(r'/posts/<id>/<slug>', PostsController.Details);
    router.get(r'/admin/new_post', PostsController.New);
    router.post(r'/admin/new_post', PostsController.Create);
    router.get(r'/admin/edit_post/<id>', PostsController.Edit);
    router.post(r'/admin/edit_post/<id>', PostsController.Update);
    router.post(r'/admin/delete_post/<id>', PostsController.Delete);

    router.get(r'/comments', CommentsController.Index);
    router.get(r'/comments/<id>', CommentsController.Details);
    router.post(r'/new_comment?post=<postId>', CommentsController.Create);
    router.get(r'/admin/edit_comment/<id>', CommentsController.Edit);
    router.post(r'/admin/edit_comment/<id>', CommentsController.Update);
    router.post(r'/admin/delete_comment/<id>', CommentsController.Delete);

    router.get(r'/tags', TagsController.Index);
    router.get(r'/tags/<slug>', TagsController.Details);
    router.get(r'/admin/new_tag', TagsController.New);
    router.post(r'/admin/new_tag', TagsController.Create);
    router.get(r'/admin/edit_tag/<id>', TagsController.Edit);
    router.post(r'/admin/edit_tag/<id>', TagsController.Update);
    router.post(r'/admin/delete_tag/<id>', TagsController.Delete);

    router.get(r'/admin/users', UsersController.Index);
    router.get(r'/admin/new_user', UsersController.New);
    router.post(r'/admin/new_user', UsersController.Create);
    router.get(r'/admin/edit_user/<id>', UsersController.Edit);
    router.post(r'/admin/edit_user/<id>', UsersController.Update);
    router.post(r'/admin/delete_user/<id>', UsersController.Delete);

    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all(r'/<ignored|.*>', (Request request) => HtmlResponse.notFound());

    var handler = const Pipeline()
        .addMiddleware(bodyParser(storeOriginalBuffer: false))
        .addMiddleware(cookieParser())
        .addMiddleware(authParser())
        .addHandler(router);

    return handler;
  }
}
