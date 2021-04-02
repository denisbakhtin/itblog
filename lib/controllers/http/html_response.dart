import 'package:shelf/shelf.dart';

class HtmlResponse extends Response {
  HtmlResponse.ok(body,
      {Map<String, Object> headers = const {},
      Map<String, Object> context = const {}})
      : super(200,
            headers: _adjustHtmlHeaders(headers), body: body, context: context);

  HtmlResponse.forbidden(
      {body,
      Map<String, Object> headers = const {},
      Map<String, Object> context = const {}})
      : super(403,
            headers: _adjustHtmlHeaders(headers), body: body, context: context);

  //TODO: return a 404 error html page
  HtmlResponse.notFound(
      {body,
      Map<String, Object> headers = const {},
      Map<String, Object> context = const {}})
      : super(404,
            headers: _adjustHtmlHeaders(headers), body: body, context: context);

  HtmlResponse.internalServerError(
      {body,
      Map<String, Object> headers = const {},
      Map<String, Object> context = const {}})
      : super(500,
            headers: _adjustHtmlHeaders(headers), body: body, context: context);

//  HtmlResponse(int statusCode,
//      {body,
//      Map<String, Object> headers = const {},
//      Map<String, Object> context = const {}})
//      : super(statusCode,
//            headers: _adjustHtmlHeaders(headers),
//            body: json.encode(body),
//            context: context,
//            encoding: null);

  /// Adds content-type information to [headers].
  /// Returns a new map without modifying [headers]
  static Map<String, Object> _adjustHtmlHeaders(Map<String, Object> headers) {
    if (headers['content-type'] == null) {
      return _addHeader(headers, 'content-type', 'text/html; charset=UTF-8');
    }
    return headers;
  }

  /// Adds header to [headers] map.
  /// Returns a new map without modifying [headers]
  static Map<String, Object> _addHeader(
      Map<String, Object> headers, String name, String value) {
    headers = Map.from(headers);
    headers[name] = value;
    return headers;
  }
}
