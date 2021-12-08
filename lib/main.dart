import 'package:args/args.dart';
import 'package:injector/injector.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'config/config.dart';
import 'models/data.dart';
import 'controllers/blog_router.dart';

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption('mode', allowed: ['debug', 'release'], defaultsTo: 'debug');
  final arguments = parser.parse(args);

  final config = Configs.load().mode(arguments['mode']);
  var db = DB(config.database);
  final injector = Injector.appInstance;
  injector.registerSingleton<Config>(() => config);
  injector.registerSingleton<DB>(() => db);

  var service = BlogRouter();
  // Service request using the router, note the router can also be mounted.
  print(
      'Starting server on http://localhost:${config.port} in ${arguments["mode"]} mode');
  io.serve(service.rootHandler, 'localhost', config.port);
}
