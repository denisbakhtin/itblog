import 'package:translit/translit.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DBException implements Exception {
  String cause;
  DBException(this.cause);
}

class NotFoundException implements DBException {
  String cause;
  NotFoundException() : this.cause = "Record not found";
}

class ExistsException implements DBException {
  String cause;
  ExistsException() : this.cause = "Record already exists";
}

String toSlug(String title) {
  if (title.isEmpty) {
    return "_";
  }

  String text = Translit().toTranslit(source: title);
  text = text
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), "_")
      .replaceAll(RegExp('[_]{2,}'), '_');
  return text;
}

String toStr(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

int toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

String toCryptoHash(String value) {
  final bytes = utf8.encode(value);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
