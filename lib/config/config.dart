import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable()
class Config {
  final String connection;
  static const _path = 'lib/config/config.json';

  Config(this.connection);
  factory Config.load() {
    var contents = File(_path).readAsStringSync();
    return Config.fromJson(json.decode(contents));
  }
  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
