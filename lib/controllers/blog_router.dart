import 'package:itblog/config/config.dart';
import 'package:itblog/views/views.dart';
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';
import 'package:shelf_static/shelf_static.dart';

import 'archives_controller.dart';
import 'auth_controller.dart';
import 'comments_controller.dart';
import 'home_controller.dart';
import 'http/auth_parser.dart';
import 'http/catch_errors.dart';
import 'http/content_type.dart';
import 'http/context_data.dart';
import 'http/shelf.dart';
import 'mailings_controller.dart';
import 'pages_controller.dart';
import 'posts_controller.dart';
import 'subscribers_controller.dart';
import 'tags_controller.dart';
import 'uploads_controller.dart';
import 'users_controller.dart';

class BlogRouter {
  Handler get rootHandler {
    final router = Router();

    //serve all static files under /public/ url. Consider using cascade router with static files coming first, web urls next
    router.mount('/public/',
        createStaticHandler('lib/public', defaultDocument: 'robots.txt'));

    router.mount('/', htmlHandler);
    return router;
  }

  Handler get htmlHandler {
    final router = Router();

    //fix shelf trailing '/' issue with nginx proxy
    // public urls
    router.get('/', HomeController.Index);
    router.mount(r'/pages', PagesController().router);
    router.mount(r'/posts', PostsController().router);
    router.mount(r'/archives', ArchivesController().router);
    router.mount(r'/comments', CommentsController().router);
    router.mount(r'/tags', TagsController().router);
    router.mount(r'/auth', AuthController().router);
    router.mount(r'/subscribers', SubscribersController().router);

    // admin urls
    router.mount("/admin/", adminHandler);
    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));

    final config = Injector.appInstance.get<Config>();
    var handler = const Pipeline()
        .addMiddleware(contentType())
        .addMiddleware(catchErrors())
        .addMiddleware(bodyParser(storeOriginalBuffer: false))
        .addMiddleware(cookieParser(config.cookieSecret))
        .addMiddleware(contextData())
        .addHandler(router);

    return handler;
  }

  Handler get adminHandler {
    final router = Router();
    // admin urls
    router.mount(r'/pages', AdminPagesController().router);
    router.mount(r'/posts', AdminPostsController().router);
    router.mount(r'/comments', AdminCommentsController().router);
    router.mount(r'/tags', AdminTagsController().router);
    router.mount(r'/users', AdminUsersController().router);
    router.mount(r'/subscribers', AdminSubscribersController().router);
    router.mount(r'/mailings', AdminMailingsController().router);
    router.post(r'/upload', AdminUploadsController.Upload);

    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));

    var handler =
        const Pipeline().addMiddleware(authParser()).addHandler(router);

    return handler;
  }
}
