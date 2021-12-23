import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:itblog/models/helpers.dart';
import 'package:path/path.dart';

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
  final bool isSignupEnabled;
  final String siteName;
  final String mode;

<<<<<<< HEAD
  Config(this.port, this.database, this.cookieSecret);
=======
  Config(this.port, this.database, this.cookieSecret, this.isSignupEnabled,
      this.siteName, this.mode);

>>>>>>> sass
  factory Config.fromJson(Map<String, dynamic> map) {
    return Config(
      toInt(map['port']),
      toStr(map['database']),
      toStr(map['cookie_secret']),
      toBool(map['is_signup_enabled']),
      toStr(map['site_name']),
      toStr(map['mode']),
    );
  }
}
