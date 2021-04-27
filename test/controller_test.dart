import 'package:itblog/config/config.dart';
import 'package:itblog/controllers/blog_router.dart';
import 'package:itblog/controllers/http/shelf.dart';
import 'package:itblog/models/data.dart';
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() async {
  Setup();
  CleanDB();
  final db = Injector.appInstance.get<DB>();
  final config = Injector.appInstance.get<Config>();
  late final Handler router = BlogRouter().handler;

  //setUp is run every time before and after each test
  setUp(() {});

  expectStatusCode(int code, Response response) async {
    expect(response.statusCode, equals(code));
    expect(response.headers["content-type"], "text/html; charset=UTF-8");
    if (response.statusCode != 301)
      expect((await response.readAsString()).length, greaterThan(0));
  }

  test("/ is accessible", () async {
    final Response response =
        await router(Request('GET', Uri.parse('http://localhost:8080/')));
    await expectStatusCode(200, response);
  });

  //_______________ PAGES ______________________
  test("/admin/pages is accessible", () async {
    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/admin/pages')));
    await expectStatusCode(200, response);
  });

  test("/pages/<id>/<slug> is accessible", () async {
    var pages = await db.pages();
    pages.forEach((p) async {
      final Response response = await router(Request(
          'GET', Uri.parse('http://localhost:8080/pages/${p.id}/${p.slug}')));
      await expectStatusCode(200, response);
    });

    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/pages/abc')));
    await expectStatusCode(404, response);
  });

  test("/admin/new_page is accessible", () async {
    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/admin/new_page')));
    await expectStatusCode(200, response);
  });

  test("/admin/new_page creates a new page", () async {
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/admin/new_page'),
        body: "title=Page123&content=Content456&id=0",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    //new page is created in db
    var page = db.pages().last;
    expect(page.title, "Page123");
    expect(page.content, "Content456");
    expect(page.published, 0);
    expect(page.id > 0, true);
  });

  test("/admin/edit_page is accessible", () async {
    final Response response = await router(Request(
        'GET', Uri.parse('http://localhost:8080/admin/edit_page/100000')));
    await expectStatusCode(404, response);

    var page = db.pages().last;
    final Response response2 = await router(Request(
        'GET', Uri.parse('http://localhost:8080/admin/edit_page/${page.id}')));
    await expectStatusCode(200, response2);
  });

  test("/admin/edit_page updates page", () async {
    var page = db.pages().last;
    expect(page.title != "Page789", true);
    expect(page.content != "Content564", true);
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/admin/edit_page/${page.id}'),
        body: "title=Page789&content=Content564&id=${page.id}",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    page = db.page(page.id);
    expect(page.title, "Page789");
    expect(page.content, "Content564");
  });

  test("/admin/delete_page deletes page", () async {
    var pages = db.pages();
    var page = pages.last;
    final Response response = await router(Request('POST',
        Uri.parse('http://localhost:8080/admin/delete_page/${page.id}')));
    await expectStatusCode(301, response);
    var pagesAfter = db.pages();
    expect(pages.length - 1, pagesAfter.length);
    if (pagesAfter.length > 0) {
      expect(pagesAfter.last.id != page.id, true);
    }
  });

  //_______________ POSTS ______________________
  test("/posts is accessible", () async {
    final Response response =
        await router(Request('GET', Uri.parse('http://localhost:8080/posts')));
    await expectStatusCode(200, response);
  });

  test("/admin/posts is accessible", () async {
    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/admin/posts')));
    await expectStatusCode(200, response);
  });

  test("/posts/<id>/<slug> is accessible", () async {
    var posts = db.posts();
    posts.forEach((p) async {
      final Response response = await router(Request(
          'GET', Uri.parse('http://localhost:8080/posts/${p.id}/${p.slug}')));
      await expectStatusCode(200, response);
    });

    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/posts/abc')));
    await expectStatusCode(404, response);
  });

  test("/admin/new_post is accessible", () async {
    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/admin/new_post')));
    await expectStatusCode(200, response);
  });

  test("/admin/new_post creates a new post", () async {
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/admin/new_post'),
        body: "title=Post123&content=Content456&id=0",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    //new post is created in db
    var post = db.posts().last;
    expect(post.title, "Post123");
    expect(post.content, "Content456");
    expect(post.published, 0);
    expect(post.id > 0, true);
  });

  test("/admin/edit_post is accessible", () async {
    final Response response = await router(Request(
        'GET', Uri.parse('http://localhost:8080/admin/edit_post/100000')));
    await expectStatusCode(404, response);

    var post = db.posts().last;
    final Response response2 = await router(Request(
        'GET', Uri.parse('http://localhost:8080/admin/edit_post/${post.id}')));
    await expectStatusCode(200, response2);
  });

  test("/admin/edit_post updates post", () async {
    var post = db.posts().last;
    expect(post.title != "Post789", true);
    expect(post.content != "Content564", true);
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/admin/edit_post/${post.id}'),
        body: "title=Post789&content=Content564&id=${post.id}",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    post = db.post(post.id);
    expect(post.title, "Post789");
    expect(post.content, "Content564");
  });

  test("/admin/delete_post deletes post", () async {
    var posts = db.posts();
    var post = posts.last;
    final Response response = await router(Request('POST',
        Uri.parse('http://localhost:8080/admin/delete_post/${post.id}')));
    await expectStatusCode(301, response);
    var postsAfter = db.posts();
    expect(posts.length - 1, postsAfter.length);
    if (postsAfter.length > 0) {
      expect(postsAfter.last.id != post.id, true);
    }
  });

  //_______________ COMMENTS ______________________
  test("/comments is accessible", () async {
    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/comments')));
    await expectStatusCode(200, response);
  });

  //_______________ TAGS ______________________
  test("/tags is accessible", () async {
    final Response response =
        await router(Request('GET', Uri.parse('http://localhost:8080/tags')));
    await expectStatusCode(200, response);
  });

  test("/tags/<slug> is accessible", () async {
    var tags = db.tags();
    tags.forEach((t) async {
      final Response response = await router(
          Request('GET', Uri.parse('http://localhost:8080/tags/${t.slug}')));
      await expectStatusCode(200, response);
    });
  });

  //_______________ USERS ______________________
  test("/admin/users is accessible", () async {
    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/admin/users')));
    await expectStatusCode(200, response);
  });

  test("/signup creates user and authenticates", () async {
    var users = db.users();
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/signup'),
        body: "email=user@admin.com&password=123456&name=Denis",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    final usersAfter = db.users();
    expect(usersAfter.length, users.length + 1);
    final user = usersAfter.last;
    expect(user.name, "Denis");
    expect(user.email, "user@admin.com");
    expect(user.hasPassword("123456"), true);
    final cp = CookieParser.fromCookieValue(response.headers["set-cookie"]);
    final cookie = await cp.getEncrypted("user", config.cookieSecret);
    expect(cookie != null, true);
    expect(cookie!.value, user.id.toString());
  });

  test("/signup fails to create existing user", () async {
    var users = db.users();
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/signup'),
        body: "email=user@admin.com&password=123&name=Denissimo",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    expect(response.headers["location"], "/signup?error=1");
    final usersAfter = db.users();
    expect(usersAfter.length, users.length);
  });

  test("/signin authenticates", () async {
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/signin'),
        body: "email=user@admin.com&password=123456",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    expect(response.headers["location"], "/admin/posts");
    final cp = CookieParser.fromCookieValue(response.headers["set-cookie"]);
    final cookie = await cp.getEncrypted("user", config.cookieSecret);
    expect(cookie != null, true);
    expect(cookie!.value.length > 0, true);
  });

  test("/signin fails to authenticates with wrong credentials", () async {
    final Response response = await router(Request(
        'POST', Uri.parse('http://localhost:8080/signin'),
        body: "email=user@admin.com&password=wrong",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response);
    expect(response.headers["location"], "/signin?error=1");
    final cp = CookieParser.fromCookieValue(response.headers["set-cookie"]);
    final cookie = await cp.getEncrypted("user", config.cookieSecret);
    expect(cookie, null);

    final Response response2 = await router(Request(
        'POST', Uri.parse('http://localhost:8080/signin'),
        body: "email=user1@admin.com&password=123456",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectStatusCode(301, response2);
    expect(response2.headers["location"], "/signin?error=1");
    final cp2 = CookieParser.fromCookieValue(response2.headers["set-cookie"]);
    final cookie2 = await cp2.getEncrypted("user", config.cookieSecret);
    expect(cookie2, null);
  });

  //_______________ MISC ______________________
  test("/non-existent returns 404", () async {
    final Response response = await router(
        Request('GET', Uri.parse('http://localhost:8080/non-existent')));
    await expectStatusCode(404, response);
  });
}
