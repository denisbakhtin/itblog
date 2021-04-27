import 'data.dart';

class SigninVM {
  String email;
  String password;
  SigninVM({this.email = '', this.password = ''});

  factory SigninVM.fromMap(Map<String, dynamic> map) {
    return SigninVM(
      email: toStr(map['email']),
      password: toStr(map['password']),
    );
  }
}

class SignupVM {
  String email;
  String name;
  String password;
  SignupVM({this.email = '', this.name = '', this.password = ''});

  factory SignupVM.fromMap(Map<String, dynamic> map) {
    return SignupVM(
      email: toStr(map['email']),
      name: toStr(map['name']),
      password: toStr(map['password']),
    );
  }
}
