import 'package:itblog/config/config.dart';
import 'package:itblog/models/data.dart';

import 'http/shelf.dart';

Map<String, dynamic> viewData(Request request) => {
      'hideSidebar': false,
      'context': request.context,
      'isAuthenticated': request.context['user'] != null,
      'user': request.context['user'],
      'path': request.requestedUri.path,
      'name': Injector.appInstance.get<Config>().siteName,
      'isDebug': Injector.appInstance.get<Config>().mode == "debug",
    };

String getOauthName() {
  return '';
}

String getSiteName() {
  return 'IT Блог';
}

List<Tag> getTags() {
  final db = Injector.appInstance.get<DB>();
  return db.tags();
}

DateTime now() {
  return DateTime.now();
}

List<String> getSessionMessages() {
  return [];
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

class Error400 implements Exception {}

class Error403 implements Exception {}

class Error404 implements Exception {}

class Error500 implements Exception {
  String message;
  Error500([this.message = ""]);
}
