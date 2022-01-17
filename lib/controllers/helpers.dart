import 'dart:convert';
import 'dart:io';

import 'package:itblog/config/config.dart';
import 'package:itblog/models/data.dart';
import 'package:path/path.dart';
import 'package:shelf_secure_cookie/shelf_secure_cookie.dart';

import 'http/shelf.dart';

Map<String, dynamic> viewData(Request request) {
  final vd = {
    'hideSidebar': false,
    'context': request.context,
    'isAuthenticated': request.context['user'] != null,
    'user': request.context['user'],
    'path': request.requestedUri.path,
    'name': Injector.appInstance.get<Config>().siteName,
    'isDebug': Injector.appInstance.get<Config>().mode == "debug",
    'message': getMessage(request),
  };
  return vd;
}

String getOauthName() {
  return '';
}

String getSiteName() {
  return Injector.appInstance.get<Config>().siteName;
}

List<Tag> getTags() {
  final db = Injector.appInstance.get<DB>();
  return db.tags();
}

DateTime now() {
  return DateTime.now();
}

bool isSignupEnabled() {
  final config = Injector.appInstance.get<Config>();
  return config.isSignupEnabled;
}

List<Post> getRecentPosts() {
  final db = Injector.appInstance.get<DB>();
  return db.recentPosts();
}

List<Archive> getArchives() {
  final db = Injector.appInstance.get<DB>();
  return db.archives();
}

List<Pagination> getPaginator(int postsCount, {int currentPage = 1}) {
  if (postsCount <= postsPerPage) return [];
  final List<Pagination> result = [];

  //prev url
  if (currentPage > 1) {
    if (currentPage == 2) {
      result.add(Pagination(title: '<<', url: '${Post.pubIndexUrl}'));
    } else {
      result.add(Pagination(
          title: '<<', url: '${Post.pubIndexUrl}?page=${currentPage - 1}'));
    }
  }

  //pages
  final count = (postsCount / postsPerPage).ceil();

  result.add(Pagination(
      title: '1', url: '${Post.pubIndexUrl}', active: currentPage == 1));
  for (var i = 2; i <= count; i++) {
    result.add(Pagination(
      title: '$i',
      url: '${Post.pubIndexUrl}?page=$i',
      active: i == currentPage,
    ));
  }

  //next url
  if (currentPage < count) {
    result.add(Pagination(
        title: '>>', url: '${Post.pubIndexUrl}?page=${currentPage + 1}'));
  }
  return result;
}

Future buildSitemapXML() async {
  final db = Injector.appInstance.get<DB>();
  final header = '''<?xml version="1.0" encoding="UTF-8"?>
  <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">''';
  final footer = '''</urlset>''';
  String postTemplate(Post post) {
    return '''<url>
      <loc>http://www.itblog.website${post.url}</loc>
      <lastmod>${post.createdSitemap}</lastmod>
      <changefreq>monthly</changefreq>
      <priority>0.9</priority>
   </url>''';
  }

  String blogTemplate() {
    return '''<url>
      <loc>http://www.itblog.website/posts</loc>
      <changefreq>monthly</changefreq>
      <priority>0.8</priority>
   </url>''';
  }

  String tagTemplate(Tag tag) {
    return '''<url>
      <loc>http://www.itblog.website${tag.url}</loc>
      <changefreq>monthly</changefreq>
      <priority>0.7</priority>
   </url>''';
  }

  String pageTemplate(Page page) {
    return '''<url>
      <loc>http://www.itblog.website${page.url}</loc>
      <changefreq>monthly</changefreq>
      <priority>0.5</priority>
   </url>''';
  }

  final posts = db.posts(published: 1);
  String result = header;
  for (final p in posts) {
    result += postTemplate(p);
  }
  result += blogTemplate();
  final pages = db.pages(published: 1);
  for (final p in pages) {
    result += pageTemplate(p);
  }
  result += footer;
  final _path = join(Directory.current.path, 'lib', 'public', 'sitemap.xml');
  await File(_path).writeAsString(result, flush: true);
}

void setMessage(Request request, String message) {
  final cookies = request.context['cookies'] as CookieParser;
  cookies.set('message', base64Url.encode(utf8.encode(message)), path: '/');
}

String? getMessage(Request request) {
  final cookies = request.context['cookies'] as CookieParser;
  final message = cookies.get('message')?.value;
  if (message != null) {
    //tell browser to delete it
    cookies.set(
      'message',
      '',
      path: '/',
      expires: DateTime.now().add(-Duration(days: 30)),
      maxAge: -Duration(days: 30).inSeconds,
    );
  }
  final decodedMessage =
      message != null ? utf8.decode(base64Url.decode(message)) : null;
  return decodedMessage;
}

class Error400 implements Exception {}

class Error403 implements Exception {}

class Error404 implements Exception {}

class Error500 implements Exception {
  String message;
  Error500([this.message = ""]);
}
