import 'dart:io';

import 'package:args/args.dart';
import 'package:injector/injector.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';

import 'config/config.dart';
import 'controllers/blog_router.dart';
import 'models/data.dart';

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption('mode', allowed: ['debug', 'release'], defaultsTo: 'debug');
  final arguments = parser.parse(args);
  final mode = arguments['mode'];

  final config = Configs.load().mode(mode);
  var db = DB(config.database);
  final injector = Injector.appInstance;
  injector.registerSingleton<Config>(() => config);
  injector.registerSingleton<DB>(() => db);
  if (mode == 'debug') {
    withHotreload(() => createServer(config, mode));
  } else {
    await createServer(config, mode);
  }
}

Future<HttpServer> createServer(Config config, String mode) {
  print(
      'Starting server with hotreload on http://localhost:${config.port} in $mode mode');
  var service = BlogRouter();
  return io.serve(service.rootHandler, 'localhost', config.port);
}
