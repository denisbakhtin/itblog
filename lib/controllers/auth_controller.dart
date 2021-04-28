import 'package:itblog/models/data.dart';
import 'package:itblog/views/views.dart';
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';

import 'http/shelf.dart';

class AuthController {
  static Future<Response> Signin(Request request) async {
    var query = request.context['query'] as Map<String, dynamic>;
    return HtmlResponse.ok(AuthSigninView(viewData: {
      'title': 'Вход в систему',
      'error': query['error'],
    }));
  }

  static Future<Response> DoSignin(Request request) async {
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
        expires: DateTime.now().add(Duration(days: 30)),
      );

      return HtmlResponse.movedPermanently("/admin/posts");
    } on NotFoundException {
      return HtmlResponse.movedPermanently("/signin?error=1");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }

  static Future<Response> Signup(Request request) async {
    var query = request.context['query'] as Map<String, dynamic>;
    return HtmlResponse.ok(AuthSignupView(viewData: {
      'title': 'Регистрация',
      'error': query['error'],
    }));
  }

  static Future<Response> DoSignup(Request request) async {
    final db = Injector.appInstance.get<DB>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final user = User.fromSignupMap(form)..validate();
      final u = db.createUser(user);
      final cookies = request.context['cookies'] as CookieParser;
      await cookies.setEncrypted(
        "user",
        u.id.toString(),
        path: '/',
        expires: DateTime.now().add(Duration(days: 30)),
      );
      return HtmlResponse.movedPermanently("/admin/posts");
    } on NotValidException {
      return HtmlResponse.movedPermanently("/signup?error=2");
    } on ExistsException {
      return HtmlResponse.movedPermanently("/signup?error=1");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }
}
