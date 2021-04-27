import 'package:sqlite3/sqlite3.dart';

import 'comment.dart';
import 'data.dart';
import 'page.dart';
import 'post.dart';
import 'tag.dart';
import 'user.dart';

class DB {
  late final Database db;
  DB(String fileName) {
    db = sqlite3.open(fileName);
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

  List<Post> posts({int? published}) {
    final result = _select(
        "SELECT * FROM posts ${published != null ? 'WHERE published=' + published.toString() : ''} ORDER BY id");
    List<Post> posts = List.from(result.map((row) => Post.fromMap(row)));
    return posts;
  }

  Post post(int id) {
    final result = _select("SELECT * FROM posts WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Post post = Post.fromMap(result.first);
    return post;
  }

  int createPost(Post post) {
    if (post.slug.isEmpty) {
      post.slug = toSlug(post.title);
    }
    return _execute(
        "INSERT INTO posts (title, content, published, meta_keywords, meta_description, slug) VALUES (?, ?, ?, ?, ?, ?)",
        [
          post.title,
          post.content,
          post.published,
          post.metaKeywords,
          post.metaDescription,
          post.slug
        ]);
  }

  int updatePost(Post post) {
    if (post.slug.isEmpty) {
      post.slug = toSlug(post.title);
    }
    return _execute(
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
  }

  int deletePost(int id) {
    return _execute("DELETE FROM posts WHERE id=?", [id]);
  }

  //_____________ COMMENTS ____________________

  List<Comment> comments({int? published}) {
    final result = _select(
        "SELECT * FROM comments ${published != null ? 'WHERE published=' + published.toString() : ''} ORDER BY id");
    List<Comment> comments =
        List.from(result.map((row) => Comment.fromMap(row)));
    return comments;
  }

  Comment comment(int id) {
    final result = _select("SELECT * FROM comments WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Comment comment = Comment.fromMap(result.first);
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
    return _execute(
        "UPDATE comments SET content=?, published=?, post_id=?, user_name=? WHERE id=?",
        [
          comment.content,
          comment.published,
          comment.postId,
          comment.userName,
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

  Tag tag(int id) {
    final result = _select("SELECT * FROM tags WHERE id = ?", [id]);
    if (result.isEmpty) throw NotFoundException();
    Tag tag = Tag.fromMap(result.first);
    return tag;
  }

  Tag tagBySlug(String slug) {
    final result = _select("SELECT * FROM tags WHERE slug = ?", [slug]);
    if (result.isEmpty) throw NotFoundException();
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
}
