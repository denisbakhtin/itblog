import 'dart:io';

import 'package:injector/injector.dart';
import 'package:itblog/config/config.dart';
import 'package:itblog/models/data.dart';

void Setup() {
  File("lib/models/debug.db").copySync("lib/models/test.db");
  var config = Configs.load().mode('test');
  var db = DB(config.database);
  final injector = Injector.appInstance;
  injector.registerSingleton<DB>(() => db);
  injector.registerSingleton<Config>(() => config);
}

void CleanDB() {
  final db = Injector.appInstance.get<DB>();
  db.db.execute("delete from comments");
  db.db.execute("delete from pages");
  db.db.execute("delete from posts");
  db.db.execute("delete from posts_tags");
  db.db.execute("delete from sqlite_sequence");
  db.db.execute("delete from tags");
  db.db.execute("delete from users");
}

void Dispose() {
  final db = Injector.appInstance.get<DB>();
  db.dispose();
}
