import 'package:html/parser.dart';

import 'data.dart';

class Comment {
  int id;
  String content;
  int published;
  int postId;
  Post? post;
  String userName;
  Comment(
      {this.id = 0,
      this.content = '',
      this.published = 0,
      this.postId = 0,
      this.post = null,
      this.userName = ''});

  String get url => "/posts/$postId/abc#comment-$id";
  static String get indexUrl => "/admin/comments";
  static String get newUrl => "/comments/new";
  String get editUrl => "/admin/comments/edit/$id";
  String get deleteUrl => "/admin/comments/delete/$id";

  String get plainName {
    const limit = 150;
    final plainText =
        parse(parse(userName).body?.text).documentElement?.text ?? '';
    return plainText.length > limit
        ? plainText.substring(0, limit) + '...'
        : plainText;
  }

  String get excerpt {
    const limit = 150;
    final plainText =
        parse(parse(content).body?.text).documentElement?.text ?? '';
    return plainText.length > limit
        ? plainText.substring(0, limit) + '...'
        : plainText;
  }

  String get plainContent {
    final plainText =
        parse(parse(content).body?.text).documentElement?.text ?? '';
    return plainText;
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: toInt(map['id']),
      content: toStr(map['content']),
      published: toInt(map['published']),
      postId: toInt(map['post_id']),
      post: map['post'] != null ? Post.fromMap(map['post']) : null,
      userName: toStr(map['user_name']),
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, content: $content, published: $published, postId: $postId, userName: $userName)';
  }
}
