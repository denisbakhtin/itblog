import 'package:itblog/controllers/helpers.dart';
import 'package:itblog/views/views.dart';
import 'package:shelf/shelf.dart';

import 'shelf.dart';

/// Creates a Shelf [Middleware]
/// Ensures all exceptions are caught and corresponding html error pages returned
Middleware catchErrors() {
  return (Handler innerHandler) {
    return (Request request) {
      return Future.sync(() {
        return innerHandler(request);
      }).then((Response response) {
        return response;
      }).onError((error, stackTrace) {
        if (error is Error400) return Response(400, body: Errors400View(''));
        if (error is Error403) return Response(403, body: Errors403View());
        if (error is Error404) return Response(404, body: Errors404View());
        return Response(500,
            body: Errors500View(
                error is Error500 ? error.message : error.toString()));
      });
    };
  };
}
