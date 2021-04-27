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

  static String get newUrl => "/new_comment";
  String get editUrl => "/admin/edit_comment/$id";
  String get deleteUrl => "/admin/delete_comment/$id";

  String get excerpt => '';

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
