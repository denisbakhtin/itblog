import 'package:itblog/controllers/helpers.dart';
import 'package:shelf/shelf.dart';
import 'shelf.dart';

/// Creates a Shelf [Middleware] to parse encrypted cookie 'user'.
/// Returns 403 page if it is invalid or absent
Middleware authParser() {
  return (Handler innerHandler) {
    return (Request request) {
      return Future.sync(() async {
        if (request.context['user'] != null) return innerHandler(request);
        throw Error403();
      }).then((Response response) {
        return response;
      });
    };
  };
}
