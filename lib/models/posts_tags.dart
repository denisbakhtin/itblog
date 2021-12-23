import 'data.dart';

class PostsTags {
  int postId;
  int tagId;

  PostsTags({
    this.postId = 0,
    this.tagId = 0,
  });

  factory PostsTags.fromMap(Map<String, dynamic> map) {
    return PostsTags(
      postId: toInt(map['post_id']),
      tagId: toInt(map['tag_id']),
    );
  }

  @override
  String toString() {
    return 'PostsTags(postId: $postId, tagId: $tagId)';
  }
}
