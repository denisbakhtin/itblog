import 'package:itblog/models/data.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';

import 'shelf.dart';

/// Creates a Shelf [Middleware] to parse encrypted cookie 'user'.
/// Returns 403 page if it is invalid or absent
Middleware contextData() {
  return (Handler innerHandler) {
    return (Request request) {
      return Future.sync(() async {
        CookieParser cookies = request.context['cookies'] as CookieParser;
        final userId = await cookies.getEncrypted("user");
        if (userId != null) {
          try {
            final db = Injector.appInstance.get<DB>();
            final user = db.user(toInt(userId.value));
            //go down the pipeline
            return innerHandler(
              request.change(context: {'user': user}),
            );
          } catch (_) {
            return innerHandler(request);
          }
        }
        return innerHandler(request);
      }).then((Response response) {
        return response;
      });
    };
  };
}
