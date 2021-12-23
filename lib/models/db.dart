import 'dart:io';

import 'package:itblog/models/posts_tags.dart';
import 'package:path/path.dart';
import 'package:sqlite3/sqlite3.dart';

import 'data.dart';

const postsPerPage = 10;

class DB {
  late final Database db;
  DB(String fileName) {
    final path = join(Directory.current.path, 'lib', fileName);
    db = sqlite3.open(path);
    db.execute("PRAGMA foreign_keys = ON");
    migrate();
  }

  void dispose() => db.dispose();

  //_____________ INTERNAL _________________
  ResultSet _select(String sql, [List<Object?> parameters = const []]) {
    return db.select(sql, parameters);
  }

  int _execute(String sql, [List<Object?> parameters = const []]) {
    final stmt = db.prepare(sql);
    stmt.execute(parameters);
    final count = db.getUpdatedRows();
    stmt.dispose();
    return count;
  }

  //_____________ MIGRATIONS ____________________
  Map<int, List<String>> migrations = const {};

  int get version {
    return _select("pragma user_version").first['user_version'];
  }

  set version(int value) {
    _execute("pragma user_version = $value");
  }

  void migrate() {
    var ver = version;
    var migs = migrations[ver];
    while (migs != null) {
      _execute('BEGIN TRANSACTION');
      try {
        for (var m in migs) {
          _execute(m);
        }
        version = ++ver;
        _execute('COMMIT');
        print('Successfully applied ${migs.length} migrations.');
      } catch (e) {
        print('Error applying migrations: $e');
        _execute('ROLLBACK');
      }
      migs = migrations[ver];
    }
  }

  //_____________ USERS ____________________

  List<User> users() {
    final result = _select("SELECT * FROM users ORDER BY id");
    List<User> users = List.from(result.map((row) => User.fromMap(row)));
    return users;
  }

  User user(int id) {
    final result = _select("SELECT * FROM users WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    final user = User.fromMap(result.first);
    return user;
  }

  User userByEmail(String email) {
    final result = _select(
        "SELECT * FROM users WHERE email = ?", [email.toLowerCase().trim()]);
    if (result.isEmpty) throw NotFoundException();
    final user = User.fromMap(result.first);
    return user;
  }

  User createUser(User user) {
    user.email = user.email.toLowerCase().trim();
    final check = _select("SELECT * FROM users WHERE email = ?", [user.email]);
    if (!check.isEmpty) throw ExistsException();
    user.password = toCryptoHash(user.password);
    _execute("INSERT INTO users (name, email, password) VALUES (?, ?, ?)", [
      user.name,
      user.email,
      user.password,
    ]);
    //before migrating to sqlite 3.35, which supports RETURNING statement
    //it is ok to use this in a low concurrency scenario
    //but obviously it is a security flaw
    final result = _select("SELECT * FROM users ORDER BY id DESC LIMIT 1");
    if (result.isEmpty) throw NotFoundException();
    final u = User.fromMap(result.first);
    return u;
  }

  int updateUser(User user) {
    user.password = toCryptoHash(user.password);
    return _execute("UPDATE users SET name=?, email=?, password=? WHERE id=?",
        [user.name, user.email, user.password, user.id]);
  }

  int deleteUser(int id) {
    return _execute("DELETE FROM users WHERE id=?", [id]);
  }

  //_____________ PAGES ____________________

  List<Page> pages() {
    final result = _select("SELECT * FROM pages ORDER BY id");
    List<Page> pages = List.from(result.map((row) => Page.fromMap(row)));
    return pages;
  }

  Page page(int id) {
    var result = _select("SELECT * FROM pages WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Page page = Page.fromMap(result.first);
    return page;
  }

  //return number of affected rows
  int createPage(Page page) {
    if (page.slug.isEmpty) {
      page.slug = toSlug(page.title);
    }
    return _execute(
        "INSERT INTO pages (title, content, published, meta_keywords, meta_description, slug) VALUES (?, ?, ?, ?, ?, ?)",
        [
          page.title,
          page.content,
          page.published,
          page.metaKeywords,
          page.metaDescription,
          page.slug
        ]);
  }

  //return number of affected rows
  int updatePage(Page page) {
    if (page.slug.isEmpty) {
      page.slug = toSlug(page.title);
    }
    return _execute(
        "UPDATE pages SET title=?, content=?, published=?, meta_keywords=?, meta_description=?, slug=? WHERE id=?",
        [
          page.title,
          page.content,
          page.published,
          page.metaKeywords,
          page.metaDescription,
          page.slug,
          page.id
        ]);
  }

  int deletePage(int id) {
    return _execute("DELETE FROM pages WHERE id=?", [id]);
  }

  //_____________ POSTS ____________________

  int postsCount({int? published}) {
    final result = _select(
        "SELECT count(*) as c FROM posts ${published != null ? 'WHERE published=' + published.toString() : ''}");
    return result.first['c'];
  }

  List<Post> posts({int? published, int? page}) {
    final result = _select(
        "SELECT * FROM posts ${published != null ? 'WHERE published=' + published.toString() : ''} ORDER BY id ${page != null ? 'LIMIT ' + postsPerPage.toString() + ' OFFSET ' + ((page - 1) * postsPerPage).toString() : ''}");
    List<Post> posts = List.from(result.map((row) => Post.fromMap(row)));
    return posts;
  }

  List<Post> recentPosts() {
    final result = _select(
        "SELECT * FROM posts WHERE published=1 ORDER BY id desc limit 4");
    List<Post> posts = List.from(result.map((row) => Post.fromMap(row)));
    return posts;
  }

  Post post(int id, {bool loadRelations = false}) {
    final result = _select("SELECT * FROM posts WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Post post = Post.fromMap(result.first);
    if (loadRelations) {
      final t = _select(
          "SELECT * FROM tags INNER JOIN posts_tags ON tags.id = posts_tags.tag_id WHERE posts_tags.post_id = ? ORDER BY tags.id",
          [id]);
      post.tags = List.from(t.map((row) => Tag.fromMap(row)));

      final c = _select(
          "SELECT * FROM comments WHERE post_id = ? and published = 1 ORDER BY id",
          [id]);
      post.comments = List.from(c.map((row) => Comment.fromMap(row)));
    }
    return post;
  }

  Post _lastPost() {
    final result = _select("SELECT * FROM posts ORDER BY id desc limit 1");
    if (result.isEmpty) throw NotFoundException();
    Post post = Post.fromMap(result.first);
    return post;
  }

  void _updatePostTags(Post post) {
    var tags =
        post.tags?.map((e) => tagByTitle(e.title, create: true)).toList() ?? [];
    var postsTags = _postsTags(post.id);
    var oldTagIds = postsTags.map((e) => e.tagId).toList();
    var newTagIds = tags.map((e) => e.id).toList();
    var idsToRemove =
        oldTagIds.where((element) => !newTagIds.contains(element)).toList();
    var idsToInsert =
        newTagIds.where((element) => !oldTagIds.contains(element)).toList();
    idsToRemove.forEach(
      (id) => _execute(
          "DELETE FROM posts_tags WHERE post_id = ? AND tag_id = ?",
          [post.id, id]),
    );
    idsToInsert.forEach(
      (id) => _execute("INSERT INTO posts_tags (post_id, tag_id) VALUES (?, ?)",
          [post.id, id]),
    );
  }

  List<PostsTags> _postsTags(int postId) {
    final result = _select(
        "SELECT * FROM posts_tags WHERE post_id=? ORDER BY tag_id asc",
        [postId]);
    List<PostsTags> postsTags =
        List.from(result.map((row) => PostsTags.fromMap(row)));
    return postsTags;
  }

  int createPost(Post post) {
    if (post.slug.isEmpty) {
      post.slug = toSlug(post.title);
    }
    var result = _execute(
        "INSERT INTO posts (title, content, published, meta_keywords, meta_description, slug) VALUES (?, ?, ?, ?, ?, ?)",
        [
          post.title,
          post.content,
          post.published,
          post.metaKeywords,
          post.metaDescription,
          post.slug
        ]);

    _updatePostTags(_lastPost()..tags = post.tags);
    return result;
  }

  int updatePost(Post post) {
    if (post.slug.isEmpty) {
      post.slug = toSlug(post.title);
    }

    var result = _execute(
        "UPDATE posts SET title=?, content=?, published=?, meta_keywords=?, meta_description=?, slug=? WHERE id=?",
        [
          post.title,
          post.content,
          post.published,
          post.metaKeywords,
          post.metaDescription,
          post.slug,
          post.id
        ]);
    _updatePostTags(post);
    return result;
  }

  int deletePost(int id) {
    return _execute("DELETE FROM posts WHERE id=?", [id]);
  }

  //_____________ ARCHIVES ____________________

  List<Archive> archives() {
    final result = _select(
        "SELECT DISTINCT strftime('%Y-%m', created_at) as date FROM posts WHERE published = 1 ORDER BY id desc");
    return List.from(result.map((row) => Archive.fromMap(row)));
  }

  List<Post> archive(String year, String month) {
    final result = _select(
        "SELECT * FROM posts WHERE published=1 AND strftime('%Y', created_at) = '${year}' and strftime('%m', created_at) = '${month}' ORDER BY id");
    List<Post> posts = List.from(result.map((row) => Post.fromMap(row)));
    return posts;
  }

  //_____________ COMMENTS ____________________

  List<Comment> comments({int? published}) {
    final result = _select(
        "SELECT * FROM comments ${published != null ? 'WHERE published=' + published.toString() : ''} ORDER BY id");
    List<Comment> comments =
        List.from(result.map((row) => Comment.fromMap(row)));
    return comments;
  }

  Comment comment(int id, {bool loadRelations = false}) {
    final result = _select("SELECT * FROM comments WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Comment comment = Comment.fromMap(result.first);

    if (loadRelations) {
      comment.post = post(comment.postId);
    }

    return comment;
  }

  int createComment(Comment comment) {
    return _execute(
        "INSERT INTO comments (content, published, post_id, user_name) VALUES (?, ?, ?, ?)",
        [
          comment.content,
          comment.published,
          comment.postId,
          comment.userName,
        ]);
  }

  int updateComment(Comment comment) {
    return _execute("UPDATE comments SET content=?, published=? WHERE id=?", [
      comment.content,
      comment.published,
      comment.id,
    ]);
  }

  int deleteComment(int id) {
    return _execute("DELETE FROM comments WHERE id=?", [id]);
  }

  //_____________ TAGS ____________________

  List<Tag> tags({int? published}) {
    final result = _select(
        "SELECT * FROM tags ${published != null ? 'WHERE published=' + published.toString() : ''} ORDER BY id");
    List<Tag> tags = List.from(result.map((row) => Tag.fromMap(row)));
    return tags;
  }

  Tag tag(int id, {bool loadRelations = false}) {
    final result = _select("SELECT * FROM tags WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Tag tag = Tag.fromMap(result.first);

    if (loadRelations) {
      final p = _select(
          "SELECT * FROM posts INNER JOIN posts_tags ON posts.id = posts_tags.post_id WHERE posts_tags.tag_id = ? AND posts.published = 1 ORDER BY posts.id",
          [id]);
      tag.posts = List.from(p.map((row) => Post.fromMap(row)));
    }

    return tag;
  }

  Tag tagBySlug(String slug, {bool loadRelations = false}) {
    final result = _select("SELECT * FROM tags WHERE slug = ?", [slug]);
    if (result.isEmpty) throw NotFoundException();
    Tag tag = Tag.fromMap(result.first);

    if (loadRelations) {
      final p = _select(
          "SELECT * FROM posts INNER JOIN posts_tags ON posts.id = posts_tags.post_id WHERE posts_tags.tag_id = ? AND posts.published = 1 ORDER BY posts.id",
          [tag.id]);
      tag.posts = List.from(p.map((row) => Post.fromMap(row)));
    }

    return tag;
  }

  //creates tag if not found when create param is true
  Tag tagByTitle(String title, {bool create = false}) {
    final result = _select("SELECT * FROM tags WHERE title = ?", [title]);
    if (result.isEmpty) {
      if (!create) throw NotFoundException();
      createTag(Tag(title: title));
      return tagByTitle(title);
    }
    Tag tag = Tag.fromMap(result.first);
    return tag;
  }

  int createTag(Tag tag) {
    if (tag.slug.isEmpty) {
      tag.slug = toSlug(tag.title);
    }
    return _execute(
        "INSERT INTO tags (title, content, published, meta_keywords, meta_description, slug) VALUES (?, ?, ?, ?, ?, ?)",
        [
          tag.title,
          tag.content,
          tag.published,
          tag.metaKeywords,
          tag.metaDescription,
          tag.slug
        ]);
  }

  int updateTag(Tag tag) {
    if (tag.slug.isEmpty) {
      tag.slug = toSlug(tag.title);
    }
    return _execute(
        "UPDATE tags SET title=?, content=?, published=?, meta_keywords=?, meta_description=?, slug=? WHERE id=?",
        [
          tag.title,
          tag.content,
          tag.published,
          tag.metaKeywords,
          tag.metaDescription,
          tag.slug,
          tag.id
        ]);
  }

  int deleteTag(int id) {
    return _execute("DELETE FROM tags WHERE id=?", [id]);
  }

  //_____________ SUBSCRIBERS ____________________

  List<Subscriber> subscribers() {
    final result = _select("SELECT * FROM subscribers ORDER BY id");
    List<Subscriber> subscribers =
        List.from(result.map((row) => Subscriber.fromMap(row)));
    return subscribers;
  }

  Subscriber subscriber(int id) {
    final result = _select("SELECT * FROM subscribers WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Subscriber subscriber = Subscriber.fromMap(result.first);

    return subscriber;
  }

  int createSubscriber(Subscriber subscriber) {
    var result = _execute("INSERT INTO subscribers (email) VALUES (?)", [
      subscriber.email.toLowerCase().trim(),
    ]);

    return result;
  }

  int updateSubscriber(Subscriber subscriber) {
    var result = _execute("UPDATE subscribers SET email=? WHERE id=?", [
      subscriber.email.toLowerCase().trim(),
      subscriber.id,
    ]);
    return result;
  }

  int deleteSubscriber(int id) {
    return _execute("DELETE FROM subscribers WHERE id=?", [id]);
  }

  //_____________ MAILINGS ____________________

  List<Mailing> mailings() {
    final result = _select("SELECT * FROM mailings ORDER BY id");
    List<Mailing> mailings =
        List.from(result.map((row) => Mailing.fromMap(row)));
    return mailings;
  }

  Mailing mailing(int id) {
    final result = _select("SELECT * FROM mailings WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Mailing mailing = Mailing.fromMap(result.first);

    return mailing;
  }

  int createMailing(Mailing mailing) {
    var result =
        _execute("INSERT INTO mailings (title, content) VALUES (?, ?)", [
      mailing.title,
      mailing.content,
    ]);

    return result;
  }

  int updateMailing(Mailing mailing) {
    var result = _execute("UPDATE mailings SET title=?, content=? WHERE id=?", [
      mailing.title,
      mailing.content,
      mailing.id,
    ]);
    return result;
  }

  int deleteMailing(int id) {
    return _execute("DELETE FROM mailings WHERE id=?", [id]);
  }
}
