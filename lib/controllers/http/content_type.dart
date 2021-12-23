import 'dart:io';
import 'package:shelf/shelf.dart';
import 'shelf.dart';

/// Creates a Shelf [Middleware]
/// Sets content-type response header to text/html if empty
Middleware contentType() {
  return (Handler innerHandler) {
    return (Request request) {
      //All my requests are html, so force this safely
      //static file handler is run without any middlewares
      return Future.sync(() {
        return innerHandler(request);
      }).then((Response response) {
        var contentType = response.headers[HttpHeaders.contentTypeHeader];
        return contentType != ContentType.html.toString() &&
                contentType != ContentType.json.toString()
            ? response.change(headers: {
                HttpHeaders.contentTypeHeader: ContentType.html.toString()
              })
            : response;
      });
    };
  };
}
