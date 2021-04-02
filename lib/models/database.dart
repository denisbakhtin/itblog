import 'page.dart';
import 'post.dart';
import 'tag.dart';
import 'user.dart';

class Database {
  Database() {}
  factory Database.connect(String connectionStr) => Database();

  List<User> users() => [];
  User user(int id) => User();
  User createUser(User user) => user;
  User updateUser(User user) => user;
  void deleteUser(int id) => null;

  List<Page> pages() => [];
  Page page(int id) => Page();
  Page createPage(Page page) => page;
  Page updatePage(Page page) => page;
  void deletePage(int id) => null;

  List<Post> posts() => [];
  Post post(int id) => Post();
  Post createPost(Post post) => post;
  Post updatePost(Post post) => post;
  void deletePost(int id) => null;

  List<Tag> tags() => [];
  Tag tag(int id) => Tag();
  Tag createTag(Tag tag) => tag;
  Tag updateTag(Tag tag) => tag;
  void deleteTag(int id) => null;
}
