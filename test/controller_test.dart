import 'dart:io';

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
  late final Handler router = BlogRouter().rootHandler;

  final user = db.createUser(
      User(email: "auth@email.com", name: "My name", password: "123456"));
  final authCp = CookieParser.fromCookieValue(null, config.cookieSecret);
  final authCookie = await authCp.setEncrypted("user", user.id.toString());

  //setUp is run every time before and after each test
  setUp(() {});

  //authenticated request
  Request aRequest(String method, String url,
      {dynamic body, Map<String, Object>? headers}) {
    headers ??= {};
    headers["cookie"] = authCookie.toString();
    return Request(method, Uri.parse(url), body: body, headers: headers);
  }

  //unauthenticated request
  Request request(String method, String url,
          {dynamic body, Map<String, Object>? headers}) =>
      Request(method, Uri.parse(url), body: body, headers: headers);

  expectStatusCode(int code, Response response) async {
    expect(response.statusCode, equals(code));
    expect(response.headers[HttpHeaders.contentTypeHeader],
        ContentType.html.toString());
    if (response.statusCode != 301)
      expect((await response.readAsString()).length, greaterThan(0));
  }

  expectRedirect(Response response, String location) async {
    expect(response.statusCode, equals(301));
    expect(response.headers[HttpHeaders.contentTypeHeader],
        ContentType.html.toString());
    expect(response.headers['location'], location);
  }

  test("/ is accessible", () async {
    final Response response =
        await router(request('GET', 'http://localhost:8080/'));
    await expectStatusCode(200, response);
  });

  //----------------------------- AUTH ---------------------------
  test("/auth/signup creates user and authenticates", () async {
    var users = db.users();
    final Response response = await router(request(
        'POST', 'http://localhost:8080/auth/signup',
        body: "email=user@admin.com&password=123456&name=Denis",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Post.indexUrl);
    final usersAfter = db.users();
    expect(usersAfter.length, users.length + 1);
    final user = usersAfter.last;
    expect(user.name, "Denis");
    expect(user.email, "user@admin.com");
    expect(user.hasPassword("123456"), true);
    final cp = CookieParser.fromCookieValue(
        response.headers["set-cookie"], config.cookieSecret);
    final cookie = await cp.getEncrypted("user");
    expect(cookie != null, true);
    expect(cookie!.value, user.id.toString());
  });

  test("/auth/signup validates form", () async {
    var users = db.users();
    Response response = await router(request(
        'POST', 'http://localhost:8080/auth/signup',
        body: "email=newuser@admin.com&password=123456",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, '/auth/signup?error=2');

    response = await router(request('POST', 'http://localhost:8080/auth/signup',
        body: "password=123456@name=denis",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, '/auth/signup?error=2');

    response = await router(request('POST', 'http://localhost:8080/auth/signup',
        body: "email=newuser@admin.com&name=denis",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, '/auth/signup?error=2');

    final usersAfter = db.users();
    expect(usersAfter.length, users.length);

    final cp = CookieParser.fromCookieValue(
        response.headers["set-cookie"], config.cookieSecret);
    final cookie = await cp.getEncrypted("user");
    expect(cookie, null);
  });

  test("/auth/signup fails to create existing user", () async {
    var users = db.users();
    final Response response = await router(request(
        'POST', 'http://localhost:8080/auth/signup',
        body: "email=user@admin.com&password=123&name=Denissimo",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, "/auth/signup?error=1");
    final usersAfter = db.users();
    expect(usersAfter.length, users.length);
  });

  test("/auth/signin authenticates", () async {
    final Response response = await router(request(
        'POST', 'http://localhost:8080/auth/signin',
        body: "email=user@admin.com&password=123456",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Post.indexUrl);
    final cp = CookieParser.fromCookieValue(
        response.headers["set-cookie"], config.cookieSecret);
    final cookie = await cp.getEncrypted("user");
    expect(cookie != null, true);
    expect(cookie!.value.length > 0, true);
  });

  test("/auth/signin fails to authenticates with wrong credentials", () async {
    final Response response = await router(request(
        'POST', 'http://localhost:8080/auth/signin',
        body: "email=user@admin.com&password=wrong",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, "/auth/signin?error=1");
    final cp = CookieParser.fromCookieValue(
        response.headers["set-cookie"], config.cookieSecret);
    final cookie = await cp.getEncrypted("user");
    expect(cookie, null);

    final Response response2 = await router(request(
        'POST', 'http://localhost:8080/auth/signin',
        body: "email=user1@admin.com&password=123456",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response2, "/auth/signin?error=1");
    final cp2 = CookieParser.fromCookieValue(
        response2.headers["set-cookie"], config.cookieSecret);
    final cookie2 = await cp2.getEncrypted("user");
    expect(cookie2, null);
  });
  //----------------------------- ADMIN --------------------------

  test("/admin/* requires auth", () async {
    final urls = [
      Page.indexUrl,
      Page.newUrl,
      Post.indexUrl,
      Post.newUrl,
      User.indexUrl,
      User.newUrl,
      Tag.indexUrl,
      Tag.newUrl,
    ];
    urls.forEach((u) async {
      final response = await router(request('GET', 'http://localhost:8080$u'));
      await expectStatusCode(403, response);
    });
  });

  //_______________ PAGES ______________________
  test("${Page.indexUrl} is accessible", () async {
    final Response response =
        await router(aRequest('GET', 'http://localhost:8080${Page.indexUrl}'));
    await expectStatusCode(200, response);
  });

  test("/pages/<id>/<slug> is accessible", () async {
    var pages = await db.pages();
    pages.forEach((p) async {
      final Response response = await router(
          request('GET', 'http://localhost:8080/pages/${p.id}/${p.slug}'));
      await expectStatusCode(200, response);
    });

    final Response response =
        await router(request('GET', 'http://localhost:8080/pages/abc'));
    await expectStatusCode(404, response);
  });

  test("${Page.newUrl} is accessible", () async {
    final Response response =
        await router(aRequest('GET', 'http://localhost:8080${Page.newUrl}'));
    await expectStatusCode(200, response);
  });

  test("${Page.newUrl} creates a new page", () async {
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080${Page.newUrl}',
        body: "title=Page123&content=Content456&id=0",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Page.indexUrl);
    //new page is created in db
    var page = db.pages().last;
    expect(page.title, "Page123");
    expect(page.content, "Content456");
    expect(page.published, 0);
    expect(page.id > 0, true);
  });

  test("/admin/pages/edit is accessible", () async {
    final Response response = await router(
        aRequest('GET', 'http://localhost:8080/admin/pages/edit/100000'));
    await expectStatusCode(404, response);

    var page = db.pages().last;
    final Response response2 = await router(
        aRequest('GET', 'http://localhost:8080/admin/pages/edit/${page.id}'));
    await expectStatusCode(200, response2);
  });

  test("/admin/pages/edit updates page", () async {
    var page = db.pages().last;
    expect(page.title != "Page789", true);
    expect(page.content != "Content564", true);
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/pages/edit/${page.id}',
        body: "title=Page789&content=Content564&id=${page.id}",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Page.indexUrl);
    page = db.page(page.id);
    expect(page.title, "Page789");
    expect(page.content, "Content564");
  });

  test("/admin/pages/delete deletes page", () async {
    var pages = db.pages();
    var page = pages.last;
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/pages/delete/${page.id}'));
    await expectRedirect(response, Page.indexUrl);
    var pagesAfter = db.pages();
    expect(pages.length - 1, pagesAfter.length);
    if (pagesAfter.length > 0) {
      expect(pagesAfter.last.id != page.id, true);
    }
  });

  //_______________ POSTS ______________________
  test("${Post.indexUrl} is accessible", () async {
    final Response response =
        await router(aRequest('GET', 'http://localhost:8080${Post.indexUrl}'));
    await expectStatusCode(200, response);
  });

  test("/posts/<id>/<slug> is accessible", () async {
    var posts = db.posts();
    posts.forEach((p) async {
      final Response response = await router(
          request('GET', 'http://localhost:8080/posts/${p.id}/${p.slug}'));
      await expectStatusCode(200, response);
    });

    final Response response =
        await router(request('GET', 'http://localhost:8080/posts/abc'));
    await expectStatusCode(404, response);
  });

  test("${Post.newUrl} is accessible", () async {
    final Response response =
        await router(aRequest('GET', 'http://localhost:8080${Post.newUrl}'));
    await expectStatusCode(200, response);
  });

  test("${Post.newUrl} creates a new post", () async {
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080${Post.newUrl}',
        body: "title=Post123&content=Content456&id=0",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Post.indexUrl);
    //new post is created in db
    var post = db.posts().last;
    expect(post.title, "Post123");
    expect(post.content, "Content456");
    expect(post.published, 0);
    expect(post.id > 0, true);
  });

  test("/admin/posts/edit is accessible", () async {
    final Response response = await router(
        aRequest('GET', 'http://localhost:8080/admin/posts/edit/100000'));
    await expectStatusCode(404, response);

    var post = db.posts().last;
    final Response response2 = await router(
        aRequest('GET', 'http://localhost:8080/admin/posts/edit/${post.id}'));
    await expectStatusCode(200, response2);
  });

  test("/admin/posts/edit updates post", () async {
    var post = db.posts().last;
    expect(post.title != "Post789", true);
    expect(post.content != "Content564", true);
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/posts/edit/${post.id}',
        body: "title=Post789&content=Content564&id=${post.id}",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Post.indexUrl);
    post = db.post(post.id);
    expect(post.title, "Post789");
    expect(post.content, "Content564");
  });

  test("/admin/posts/delete deletes post", () async {
    var posts = db.posts();
    var post = posts.last;
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/posts/delete/${post.id}'));
    await expectRedirect(response, Post.indexUrl);
    var postsAfter = db.posts();
    expect(posts.length - 1, postsAfter.length);
    if (postsAfter.length > 0) {
      expect(postsAfter.last.id != post.id, true);
    }
  });

  //_______________ COMMENTS ______________________

  //_______________ TAGS ______________________
  test("/tags/<slug> is accessible", () async {
    var tags = db.tags();
    tags.forEach((t) async {
      final Response response =
          await router(request('GET', 'http://localhost:8080/tags/${t.slug}'));
      await expectStatusCode(200, response);
    });
  });

  //_______________ USERS ______________________
  test("${User.indexUrl} is accessible", () async {
    final Response response =
        await router(aRequest('GET', 'http://localhost:8080${User.indexUrl}'));
    await expectStatusCode(200, response);
  });

  //_______________ SUBSCRIBERS ________________
  test("/subscribers/new creates a new subscriber", () async {
    var subscribers = db.subscribers();
    final Response response = await router(request(
        'POST', 'http://localhost:8080/subscribers/new',
        body: "email=user@admin.com",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, "/");
    final subscribersAfter = db.subscribers();
    expect(subscribersAfter.length, subscribers.length + 1);
    final subscriber = subscribersAfter.last;
    expect(subscriber.email, "user@admin.com");
  });

  //_______________ MAILINGS ________________
  test("/admin/mailings/new creates a new mailing", () async {
    var mailings = db.mailings();
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/mailings/new',
        body: "title=Title&content=Content",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Mailing.indexUrl);
    final mailingsAfter = db.mailings();
    expect(mailingsAfter.length, mailings.length + 1);
    final mailing = mailingsAfter.last;
    expect(mailing.title, "Title");
    expect(mailing.content, "Content");
  });

  test("${Mailing.indexUrl} is accessible", () async {
    final Response response = await router(
        aRequest('GET', 'http://localhost:8080${Mailing.indexUrl}'));
    await expectStatusCode(200, response);
  });

  test("${Mailing.newUrl} is accessible", () async {
    final Response response =
        await router(aRequest('GET', 'http://localhost:8080${Mailing.newUrl}'));
    await expectStatusCode(200, response);
  });

  test("${Mailing.newUrl} creates a new post", () async {
    var mailings = db.mailings();
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/mailings/new',
        body: "title=Title&content=Content",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Mailing.indexUrl);
    final mailingsAfter = db.mailings();
    expect(mailingsAfter.length, mailings.length + 1);
    final mailing = mailingsAfter.last;
    expect(mailing.title, "Title");
    expect(mailing.content, "Content");
  });

  test("/admin/mailings/edit is accessible", () async {
    final Response response = await router(
        aRequest('GET', 'http://localhost:8080/admin/mailings/edit/100000'));
    await expectStatusCode(404, response);

    var mailing = db.mailings().last;
    final Response response2 = await router(aRequest(
        'GET', 'http://localhost:8080/admin/mailings/edit/${mailing.id}'));
    await expectStatusCode(200, response2);
  });

  test("/admin/mailings/edit updates post", () async {
    var mailing = db.mailings().last;
    expect(mailing.title != "Title789", true);
    expect(mailing.content != "Content564", true);
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/mailings/edit/${mailing.id}',
        body: "title=Mailing789&content=Content564&id=${mailing.id}",
        headers: {'Content-Type': 'application/x-www-form-urlencoded'}));
    await expectRedirect(response, Mailing.indexUrl);
    mailing = db.mailing(mailing.id);
    expect(mailing.title, "Mailing789");
    expect(mailing.content, "Content564");
  });

  test("/admin/mailings/delete deletes mailing", () async {
    var mailings = db.mailings();
    var mailing = mailings.last;
    final Response response = await router(aRequest(
        'POST', 'http://localhost:8080/admin/mailings/delete/${mailing.id}'));
    await expectRedirect(response, Mailing.indexUrl);
    var mailingsAfter = db.mailings();
    expect(mailings.length - 1, mailingsAfter.length);
    if (mailingsAfter.length > 0) {
      expect(mailingsAfter.last.id != mailing.id, true);
    }
  });

  //_______________ MISC ______________________
  test("/non-existent returns 404", () async {
    final Response response =
        await router(request('GET', 'http://localhost:8080/non-existent'));
    await expectStatusCode(404, response);
  });
}
