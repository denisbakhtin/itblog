import 'dart:async';

import 'package:itblog/models/data.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';

import 'shelf.dart';

/// Creates a Shelf [Middleware] to parse cookies.
///
/// Adds a [CookieParser] instance to `request.context['cookies']`,
/// with convenience methods to manipulate cookies in request handlers.
///
/// Adds a `Set-Cookie` HTTP header to the response with all cookies.
shelf.Middleware authParser() {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) {
      return Future.sync(() async {
        final accept = request.headers["accept"] ?? "";
        if (accept.contains("text/html")) {
          try {
            CookieParser cookies = request.context['cookies'] as CookieParser;
            final db = Injector.appInstance.get<DB>();
            final userId = await cookies.getEncrypted("user");
            if (userId != null) {
              final user = db.user(toInt(userId.value));
              return innerHandler(request.change(context: {'user': user}));
            }
            return innerHandler(request);
          } catch (_) {
            return innerHandler(request);
          }
        } else {
          return innerHandler(request);
        }
      }).then((shelf.Response response) {
        return response;
      }, onError: (error, StackTrace stackTrace) {
        throw error;
      });
    };
  };
}
