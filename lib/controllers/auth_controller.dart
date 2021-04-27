import 'package:itblog/config/config.dart';
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
    final config = Injector.appInstance.get<Config>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final model = SigninVM.fromMap(form);
      final u = db.userByEmail(model.email);
      if (!u.hasPassword(model.password)) throw NotFoundException();
      final cookies = request.context['cookies'] as CookieParser;
      await cookies.setEncrypted(
        "user",
        u.id.toString(),
        config.cookieSecret,
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
    print('Is this even real');
    return HtmlResponse.ok(AuthSignupView(viewData: {
      'title': 'Регистрация',
      'error': query['error'],
    }));
  }

  static Future<Response> DoSignup(Request request) async {
    print('123');
    final db = Injector.appInstance.get<DB>();
    final config = Injector.appInstance.get<Config>();
    try {
      final form = request.context['postParams'] as Map<String, dynamic>;
      final user = User.fromSignupMap(form);
      print('234');
      final u = db.createUser(user);
      final cookies = request.context['cookies'] as CookieParser;
      await cookies.setEncrypted(
        "user",
        u.id.toString(),
        config.cookieSecret,
        path: '/',
        expires: DateTime.now().add(Duration(days: 30)),
      );
      return HtmlResponse.movedPermanently("/admin/posts");
    } on ExistsException {
      print('Exists Exception!!');
      return HtmlResponse.movedPermanently("/signup?error=1");
    } catch (e) {
      return HtmlResponse.internalServerError(body: e.toString());
    }
  }
}
