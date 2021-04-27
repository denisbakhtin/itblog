import 'dart:convert';
import 'dart:io';

import 'package:itblog/models/helpers.dart';

//application mode
enum Mode { debug, test, release }

class Config {
  final int port;
  final String database;
  final String cookieSecret;

  Config(this.port, this.database, this.cookieSecret);
  factory Config.load(Mode mode) {
    final _modeStr = mode.toString().split('.').last;
    final _path = 'lib/config/config_$_modeStr.json';
    var _contents = File(_path).readAsStringSync();
    return Config._fromJson(json.decode(_contents));
  }
  factory Config._fromJson(Map<String, dynamic> map) {
    return Config(
      toInt(map['port']),
      toStr(map['database']),
      toStr(map['cookie_secret']),
    );
  }
}
