import 'data.dart';

class User {
  int id;
  String email;
  String name;
  String password;
  User({this.id = 0, this.email = '', this.name = '', this.password = ''});

  String get url => "/admin/users/$id";
  static String get newUrl => "/admin/new_user";
  String get editUrl => "/admin/edit_user/$id";
  String get deleteUrl => "/admin/delete_user/$id";

  bool hasPassword(String pass) => password == toCryptoHash(pass);

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: toInt(map['id']),
      email: toStr(map['email']),
      name: toStr(map['name']),
      password: toStr(map['password']),
    );
  }

  factory User.fromSignupMap(Map<String, dynamic> map) {
    return User(
      email: toStr(map['email']),
      name: toStr(map['name']),
      password: toStr(map['password']),
    );
  }
}
