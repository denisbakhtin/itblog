import 'package:itblog/config/config.dart';
import 'package:test/test.dart';

void main() {
  test("Parses config.json", () {
    var c = Config.load();
    //c is unnullable, nothing to test :)
    //c.connection is unnullable
    assert(c.connection.length > 0);
  });
}
