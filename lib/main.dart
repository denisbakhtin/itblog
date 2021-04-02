import 'package:injector/injector.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'models/database.dart';
import 'controllers/blog_router.dart';

void main() async {
  // You can setup context, database connections, cache connections, email
  // services, before you create an instance of your service.
  var connection = await Database.connect('localhost:1234');
  final injector = Injector.appInstance;
  injector.registerSingleton<Database>(() => connection);

  // Create an instance of your service, usine one of the constructors you've
  // defined.
  var service = BlogRouter();
  // Service request using the router, note the router can also be mounted.
  var server = await io.serve(service.handler, 'localhost', 8080);
  print('Server listening on ${server.address.host}:${server.port}');
}
