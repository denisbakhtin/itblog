import 'package:itblog/controllers/helpers.dart';
import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';

import 'http/shelf.dart';

class AuthController {
  Router get router {
    final router = Router();

    router.get('/signin', (Request request) async {
      var query = request.context['query'] as Map<String, dynamic>;
      var vd = viewData(request);
      return Response.ok(AuthSigninView(
          viewData: vd
            ..['error'] = query['error']
            ..['hideSidebar'] = true));
    });

    router.post('/signin', (Request request) async {
      final db = Injector.appInstance.get<DB>();
      try {
        final form = request.context['postParams'] as Map<String, dynamic>;
        final model = SigninVM.fromMap(form);
        final u = db.userByEmail(model.email);
        if (!u.hasPassword(model.password)) throw NotFoundException();
        final cookies = request.context['cookies'] as CookieParser;
        await cookies.setEncrypted(
          "user",
          u.id.toString(),
          path: '/',
          maxAge: Duration(days: 30).inSeconds,
        );

        return Response.movedPermanently(Post.indexUrl);
      } on NotFoundException {
        return Response.movedPermanently("/auth/signin?error=1");
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.get('/signup', (Request request) async {
      if (!isSignupEnabled()) {
        return Response.movedPermanently("/");
      }
      var query = request.context['query'] as Map<String, dynamic>;
      var vd = viewData(request);
      return Response.ok(AuthSignupView(
          viewData: vd
            ..['error'] = query['error']
            ..['hideSidebar'] = true));
    });

    router.post('/signup', (Request request) async {
      if (!isSignupEnabled()) {
        return Response.movedPermanently("/");
      }
      final db = Injector.appInstance.get<DB>();
      try {
        final form = request.context['postParams'] as Map<String, dynamic>;
        final cookies = request.context['cookies'] as CookieParser;
        final user = User.fromSignupMap(form)..validate();
        final u = db.createUser(user);
        await cookies.setEncrypted(
          "user",
          u.id.toString(),
          path: '/',
          maxAge: Duration(days: 30).inSeconds,
        );
        return Response.movedPermanently(Post.indexUrl);
      } on NotValidException {
        return Response.movedPermanently("/auth/signup?error=2");
      } on ExistsException {
        return Response.movedPermanently("/auth/signup?error=1");
      } catch (e) {
        throw Error500(e.toString());
      }
    });

    router.get('/signout', (Request request) async {
      final cookies = request.context['cookies'] as CookieParser;
      cookies.set(
        "user",
        "",
        path: '/',
        expires: DateTime.now().add(-Duration(days: 30)),
        maxAge: -Duration(days: 30).inSeconds,
      );
      return Response.movedPermanently("/");
    });

    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all(r'/<ignored|.*>',
        (Request request) => Response.notFound(Errors404View()));

    return router;
  }
}
