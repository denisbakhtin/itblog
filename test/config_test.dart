import 'package:itblog/config/config.dart';
import 'package:test/test.dart';

void main() {
  test("Parses config.json", () {
    var c = Config.load(Mode.test);
    assert(c.port > 0);
    assert(c.database.length > 0);
    assert(c.cookieSecret.length > 0);
  });
}
