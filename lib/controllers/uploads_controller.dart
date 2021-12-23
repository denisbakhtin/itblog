import 'dart:io';

import 'http/shelf.dart';

class AdminUploadsController {
  static Future<Response> Upload(Request request) async {
    var files = request.context['postFileParams'] as Map<String, List<dynamic>>;
    FileParams val = files['upload']![0];
    final filename =
        "${DateTime.now().millisecondsSinceEpoch}.${val.filename!.split('.').last}";

    final file = File("lib/public/uploads/${filename}");
    if (await file.exists()) {
      await file.delete();
    }
    final parts = await val.part!.toList();
    for (final part in parts) {
      await file.writeAsBytes(part, mode: FileMode.append);
    }

    return Response.ok('{"uploaded":true,"url":"/public/uploads/${filename}"}',
        headers: {HttpHeaders.contentTypeHeader: ContentType.json.toString()});
  }
}
