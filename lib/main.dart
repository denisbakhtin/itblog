import 'dart:io';

import 'package:args/args.dart';
import 'package:injector/injector.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';

import 'config/config.dart';
import 'controllers/blog_router.dart';
<<<<<<< HEAD
import 'package:args/args.dart';
=======
import 'models/data.dart';
>>>>>>> sass

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption('mode', allowed: ['debug', 'release'], defaultsTo: 'debug');
  final arguments = parser.parse(args);
<<<<<<< HEAD

  final config = Configs.load().mode(arguments['mode']);
=======
  final mode = arguments['mode'];

  final config = Configs.load().mode(mode);
>>>>>>> sass
  var db = DB(config.database);
  final injector = Injector.appInstance;
  injector.registerSingleton<Config>(() => config);
  injector.registerSingleton<DB>(() => db);
<<<<<<< HEAD

  // Create an instance of your service, usine one of the constructors you've
  // defined.
  var service = BlogRouter();
  // Service request using the router, note the router can also be mounted.
  var server = await io.serve(service.handler, 'localhost', config.port);
  print(config.port);
  print('Server listening on http://${server.address.host}:${server.port}');
=======
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
>>>>>>> sass
}
