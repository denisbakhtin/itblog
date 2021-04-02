import 'package:itblog/models/database.dart';
import 'package:shelf_static/shelf_static.dart';

import 'comments_controller.dart';
import 'home_controller.dart';
import 'http/shelf.dart';
import 'pages_controller.dart';
import 'posts_controller.dart';
import 'tags_controller.dart';
import 'users_controller.dart';

class BlogRouter {
  final Database connection;
  BlogRouter() : connection = Injector.appInstance.get<Database>();

  Handler get handler {
    final router = Router();

    //serve all static files under /public/ url. Consider using cascade router with static files coming first, web urls next
    router.mount('/public/',
        createStaticHandler('lib/public', defaultDocument: 'robots.txt'));

    //Can't group actions in controllers atm because of this https://github.com/google/dart-neats/issues/67
    //so have to attach actions directly
//    router.mount('/', HomeController().handler);
    router.get('/', HomeController.Index);

    router.get(r'/pages', PagesController.Index);
    router.get(r'/pages/<id>', PagesController.Details);

    router.get(r'/posts', PostsController.Index);
    router.get(r'/posts/<id>', PostsController.Details);

    router.get(r'/comments', CommentsController.Index);
    router.get(r'/comments/<id>', CommentsController.Details);

    router.get(r'/tags', TagsController.Index);
    router.get(r'/tags/<id>', TagsController.Details);

    router.get(r'/users', UsersController.Index);
    router.get(r'/users/<id>', UsersController.Details);

    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all(r'/<ignored|.*>', (Request request) => HtmlResponse.notFound());

    return router;
  }
}
