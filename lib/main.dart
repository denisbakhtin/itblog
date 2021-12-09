import 'package:injector/injector.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'config/config.dart';
import 'models/data.dart';
import 'controllers/blog_router.dart';
import 'package:args/args.dart';

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption('mode', allowed: ['debug', 'release'], defaultsTo: 'debug');
  final arguments = parser.parse(args);

  final config = Configs.load().mode(arguments['mode']);
  var db = DB(config.database);
  final injector = Injector.appInstance;
  injector.registerSingleton<Config>(() => config);
  injector.registerSingleton<DB>(() => db);

  // Create an instance of your service, usine one of the constructors you've
  // defined.
  var service = BlogRouter();
  // Service request using the router, note the router can also be mounted.
  var server = await io.serve(service.handler, 'localhost', config.port);
  print(config.port);
  print('Server listening on http://${server.address.host}:${server.port}');
}
