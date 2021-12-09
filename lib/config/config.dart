import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:itblog/models/helpers.dart';

//application mode
enum Mode { debug, test, release }

class Configs {
  final Config debug;
  final Config test;
  final Config release;

  Configs(this.debug, this.test, this.release);
  factory Configs.load() {
    final _path = join(Directory.current.path, 'lib', 'config.json');
    final _contents = File(_path).readAsStringSync();
    return Configs._fromJson(json.decode(_contents));
  }
  factory Configs._fromJson(Map<String, dynamic> map) {
    return Configs(
      Config.fromJson(map['debug']),
      Config.fromJson(map['test']),
      Config.fromJson(map['release']),
    );
  }
  Config mode(String m) {
    switch (m) {
      case 'debug':
        return debug;
      case 'release':
        return release;
      case 'test':
        return test;
      default:
        throw 'Unsupported application mode';
    }
  }
}

class Config {
  final int port;
  final String database;
  final String cookieSecret;

  Config(this.port, this.database, this.cookieSecret);
  factory Config.fromJson(Map<String, dynamic> map) {
    return Config(
      toInt(map['port']),
      toStr(map['database']),
      toStr(map['cookie_secret']),
    );
  }
}
