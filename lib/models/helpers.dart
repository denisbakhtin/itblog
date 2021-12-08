import 'package:translit/translit.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DBException implements Exception {
  String cause;
  DBException(this.cause);
}

class NotValidException implements DBException {
  String cause;
  NotValidException() : this.cause = "Model not valid";
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
      .replaceAll(RegExp('[_]{2,}'), '_')
      .replaceAll(RegExp('^[_]+'), '')
      .replaceAll(RegExp(r'[_]+$'), '');
  return text;
}

String toStr(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

bool toBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  return false;
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

String monthName(int month) {
  switch (month) {
    case 1:
      return 'Январь';
    case 2:
      return 'Февраль';
    case 3:
      return 'Март';
    case 4:
      return 'Апрель';
    case 5:
      return 'Май';
    case 6:
      return 'Июнь';
    case 7:
      return 'Июль';
    case 8:
      return 'Август';
    case 9:
      return 'Сентябрь';
    case 10:
      return 'Октябрь';
    case 11:
      return 'Ноябрь';
    case 12:
      return 'Декабрь';
    default:
      return '';
  }
}
